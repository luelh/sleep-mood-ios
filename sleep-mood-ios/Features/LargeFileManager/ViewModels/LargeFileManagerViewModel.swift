import Foundation
import SwiftUI

struct LargeTestFile: Identifiable {
    let id: String // 파일명
    let url: URL
    let size: Int
}

class LargeFileManagerViewModel: ObservableObject {
    @Published var fileSizeString: String = "-"
    @Published var resultMessage: String? = nil
    @Published var freeSpaceString: String = "-"
    @Published var isCreating: Bool = false
    @Published var isBatchCreating: Bool = false
    @Published var files: [LargeTestFile] = []
    @Published var totalFilesSizeString: String = "-"
    
    private let filePrefix = "large_test_file_"
    private let fileExt = ".dat"
    private let fileSize: Int = 1024 * 1024 * 500 // 500MB
    private let smallFilePrefix = "small_test_file_"
    private let smallFileSize: Int = 1024 * 1024 * 50 // 50MB
    private let tinyFilePrefix = "tiny_test_file_"
    private let tinyFileSize: Int = 1024 * 1024 * 5 // 5MB
    private var batchCreateTask: Task<Void, Never>? = nil
    
    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func updateFiles() {
        let fileManager = FileManager.default
        let files = (try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.fileSizeKey], options: [])) ?? []
        let testFiles = files.filter { $0.lastPathComponent.hasPrefix(filePrefix) && $0.pathExtension == "dat" }
        var fileList: [LargeTestFile] = []
        var total: Int = 0
        for url in testFiles {
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            fileList.append(LargeTestFile(id: url.lastPathComponent, url: url, size: size))
            total += size
        }
        self.files = fileList.sorted { $0.id < $1.id }
        self.totalFilesSizeString = ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .file)
        self.fileSizeString = fileList.last.map { ByteCountFormatter.string(fromByteCount: Int64($0.size), countStyle: .file) } ?? "-"
        updateFreeSpace()
    }
    
    func updateFreeSpace() {
        do {
            let values = try documentsURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let free = values.volumeAvailableCapacityForImportantUsage {
                freeSpaceString = ByteCountFormatter.string(fromByteCount: Int64(free), countStyle: .file)
            } else {
                freeSpaceString = "-"
            }
        } catch {
            freeSpaceString = "-"
        }
    }
    
    @MainActor
    func createLargeFile() {
        guard !isCreating && !isBatchCreating else { return }
        isCreating = true
        resultMessage = "파일 생성 중..."
        Task {
            let url = documentsURL.appendingPathComponent("\(filePrefix)\(Int(Date().timeIntervalSince1970)).dat")
            let size = self.fileSize
            let buffer = Data((0..<1024*1024).map { _ in UInt8.random(in: 0...255) }) // 1MB 랜덤 데이터

            // 남은 용량 체크
            let freeSpace = self.getFreeSpace()
            if let freeSpace = freeSpace, freeSpace < Int64(size) + 10 * 1024 * 1024 {
                await MainActor.run {
                    self.resultMessage = "저장 공간이 부족합니다. (남은 용량: \(self.freeSpaceString))"
                    self.updateFiles()
                    self.isCreating = false
                }
                return
            }

            do {
                FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
                guard let fileHandle = try? FileHandle(forWritingTo: url) else {
                    await MainActor.run {
                        self.resultMessage = "파일 핸들 생성 실패"
                        self.updateFiles()
                        self.isCreating = false
                    }
                    return
                }
                for i in 0..<(size / buffer.count) {
                    do {
                        try fileHandle.write(contentsOf: buffer)
                        if i % 50 == 0 {
                            await MainActor.run {
                                self.resultMessage = "파일 생성 중... (\(i+1)MB/\(size/1024/1024)MB)"
                            }
                        }
                    } catch {
                        await MainActor.run {
                            self.resultMessage = "쓰기 중 오류 발생 (\(i)MB까지 작성됨): \(error.localizedDescription)"
                            self.updateFiles()
                            self.isCreating = false
                        }
                        try? fileHandle.close()
                        return
                    }
                }
                try? fileHandle.close()
                await MainActor.run {
                    self.resultMessage = "파일 생성 완료: \(url.lastPathComponent)"
                    self.updateFiles()
                    self.isCreating = false
                }
            } catch {
                await MainActor.run {
                    self.resultMessage = "파일 생성 실패: \(error.localizedDescription)"
                    self.updateFiles()
                    self.isCreating = false
                }
            }
        }
    }

    // 연속 생성용: 진행상황 콜백 지원, 실패 시 에러 메시지 반환 (단일 생성용)
    @MainActor
    func createLargeFile(progressHandler: ((Int) -> Void)? = nil) async -> (Bool, String?) {
        guard !isCreating && !isBatchCreating else { return (false, nil) }
        isCreating = true
        var lastError: String? = nil
        let url = documentsURL.appendingPathComponent("\(filePrefix)\(Int(Date().timeIntervalSince1970)).dat")
        let size = self.fileSize
        let buffer = Data((0..<1024*1024).map { _ in UInt8.random(in: 0...255) }) // 1MB 랜덤 데이터

        // 남은 용량 체크
        let freeSpace = self.getFreeSpace()
        if let freeSpace = freeSpace, freeSpace < Int64(size) + 10 * 1024 * 1024 {
            let msg = "저장 공간이 부족합니다. (남은 용량: \(self.freeSpaceString))"
            self.resultMessage = msg
            self.updateFiles()
            self.isCreating = false
            return (false, msg)
        }

        do {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
            guard let fileHandle = try? FileHandle(forWritingTo: url) else {
                let msg = "파일 핸들 생성 실패"
                self.resultMessage = msg
                self.updateFiles()
                self.isCreating = false
                return (false, msg)
            }
            for i in 0..<(size / buffer.count) {
                do {
                    try fileHandle.write(contentsOf: buffer)
                    if i % 10 == 0 { // 10MB마다 갱신
                        progressHandler?(i + 1)
                    }
                } catch {
                    let msg = "쓰기 중 오류 발생 (\(i)MB까지 작성됨): \(error.localizedDescription)"
                    self.resultMessage = msg
                    self.updateFiles()
                    self.isCreating = false
                    return (false, msg)
                }
            }
            try? fileHandle.close()
            self.resultMessage = "파일 생성 완료: \(url.lastPathComponent)"
            self.updateFiles()
            self.isCreating = false
            return (true, nil)
        } catch {
            let msg = "파일 생성 실패: \(error.localizedDescription)"
            self.resultMessage = msg
            self.updateFiles()
            self.isCreating = false
            return (false, msg)
        }
    }

    // batch 생성용: isCreating 체크 없이 실제 파일 생성 시도, 백그라운드에서 실행
    func createLargeFileForBatch(progressHandler: ((Int) -> Void)? = nil) async -> (Bool, String?) {
        let url = documentsURL.appendingPathComponent("\(filePrefix)\(Int(Date().timeIntervalSince1970)).dat")
        let size = self.fileSize
        let buffer = Data((0..<1024*1024).map { _ in UInt8.random(in: 0...255) }) // 1MB 랜덤 데이터

        let freeSpace = self.getFreeSpace()
        if let freeSpace = freeSpace, freeSpace < Int64(size) + 10 * 1024 * 1024 {
            await MainActor.run {
                self.resultMessage = "저장 공간이 부족합니다. (남은 용량: \(self.freeSpaceString))"
                self.updateFiles()
            }
            return (false, "저장 공간이 부족합니다.")
        }

        do {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
            guard let fileHandle = try? FileHandle(forWritingTo: url) else {
                await MainActor.run {
                    self.resultMessage = "파일 핸들 생성 실패"
                    self.updateFiles()
                }
                return (false, "파일 핸들 생성 실패")
            }
            for i in 0..<(size / buffer.count) {
                do {
                    try fileHandle.write(contentsOf: buffer)
                    if i % 10 == 0 {
                        await MainActor.run {
                            progressHandler?(i + 1)
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.resultMessage = "쓰기 중 오류 발생 (\(i)MB까지 작성됨): \(error.localizedDescription)"
                        self.updateFiles()
                    }
                    return (false, "쓰기 중 오류 발생 (\(i)MB까지 작성됨): \(error.localizedDescription)")
                }
            }
            try? fileHandle.close()
            await MainActor.run {
                self.resultMessage = "파일 생성 완료: \(url.lastPathComponent)"
                self.updateFiles()
            }
            return (true, nil)
        } catch {
            await MainActor.run {
                self.resultMessage = "파일 생성 실패: \(error.localizedDescription)"
                self.updateFiles()
            }
            return (false, "파일 생성 실패: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func startBatchCreateFiles(count: Int) {
        guard !isBatchCreating && !isCreating else { return }
        isBatchCreating = true
        resultMessage = "여러 파일 생성 시작..."
        batchCreateTask = Task.detached { [weak self] in
            await self?.performBatchCreateFiles(count: count)
        }
    }

    @MainActor
    func performBatchCreateFiles(count: Int) async {
        var successCount = 0
        var failCount = 0
        var lastErrorMsg: String? = nil
        for i in 1...count {
            let (success, errorMsg) = await self.createLargeFileForBatch(progressHandler: { mb in
                Task { @MainActor in
                    self.resultMessage = "여러 파일 생성 중... (\(i)/\(count)번째, \(mb)MB/500MB)"
                }
            })
            if success {
                successCount += 1
            } else {
                failCount += 1
                if let errorMsg = errorMsg {
                    lastErrorMsg = errorMsg
                }
            }
        }
        self.isBatchCreating = false
        if failCount > 0 {
            self.resultMessage = "여러 파일 생성 완료 (성공: \(successCount), 실패: \(failCount))\n마지막 에러: \(lastErrorMsg ?? "-")"
        } else {
            self.resultMessage = "여러 파일 생성 완료 (성공: \(successCount), 실패: 0)"
        }
        self.updateFiles()
    }
    
    @MainActor
    func stopBatchCreateFiles() {
        batchCreateTask?.cancel()
        isBatchCreating = false
        resultMessage = "여러 파일 생성 중단됨"
    }
    
    @MainActor
    func deleteFile(_ file: LargeTestFile) {
        do {
            try FileManager.default.removeItem(at: file.url)
            resultMessage = "파일 삭제 완료: \(file.id)"
        } catch {
            resultMessage = "파일 삭제 실패: \(error.localizedDescription)"
        }
        updateFiles()
    }
    
    @MainActor
    func deleteAllFiles() {
        for file in files {
            try? FileManager.default.removeItem(at: file.url)
        }
        resultMessage = "모든 파일 삭제 완료"
        updateFiles()
    }
    
    private func getFreeSpace() -> Int64? {
        do {
            let values = try documentsURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let free = values.volumeAvailableCapacityForImportantUsage {
                return free
            }
        } catch {}
        return nil
    }

    @MainActor
    func createSmallFile() {
        guard !isCreating && !isBatchCreating else { return }
        isCreating = true
        resultMessage = "50MB 파일 생성 중..."
        Task {
            let url = documentsURL.appendingPathComponent("\(smallFilePrefix)\(Int(Date().timeIntervalSince1970)).dat")
            let size = self.smallFileSize
            let buffer = Data((0..<size).map { _ in UInt8.random(in: 0...255) }) // 50MB 랜덤 데이터

            let freeSpace = self.getFreeSpace()
            if let freeSpace = freeSpace, freeSpace < Int64(size) + 2 * 1024 * 1024 {
                await MainActor.run {
                    self.resultMessage = "저장 공간이 부족합니다. (남은 용량: \(self.freeSpaceString))"
                    self.updateFiles()
                    self.isCreating = false
                }
                return
            }

            do {
                try buffer.write(to: url)
                await MainActor.run {
                    self.resultMessage = "50MB 파일 생성 완료: \(url.lastPathComponent)"
                    self.updateFiles()
                    self.isCreating = false
                }
            } catch {
                await MainActor.run {
                    self.resultMessage = "50MB 파일 생성 실패: \(error.localizedDescription)"
                    self.updateFiles()
                    self.isCreating = false
                }
            }
        }
    }

    @MainActor
    func createTinyFile() {
        guard !isCreating && !isBatchCreating else { return }
        isCreating = true
        resultMessage = "5MB 파일 생성 중..."
        Task {
            let url = documentsURL.appendingPathComponent("\(tinyFilePrefix)\(Int(Date().timeIntervalSince1970)).dat")
            let size = self.tinyFileSize
            let buffer = Data((0..<size).map { _ in UInt8.random(in: 0...255) }) // 5MB 랜덤 데이터

            let freeSpace = self.getFreeSpace()
            if let freeSpace = freeSpace, freeSpace < Int64(size) + 2 * 1024 * 1024 {
                await MainActor.run {
                    self.resultMessage = "저장 공간이 부족합니다. (남은 용량: \(self.freeSpaceString))"
                    self.updateFiles()
                    self.isCreating = false
                }
                return
            }

            do {
                try buffer.write(to: url)
                await MainActor.run {
                    self.resultMessage = "5MB 파일 생성 완료: \(url.lastPathComponent)"
                    self.updateFiles()
                    self.isCreating = false
                }
            } catch {
                await MainActor.run {
                    self.resultMessage = "5MB 파일 생성 실패: \(error.localizedDescription)"
                    self.updateFiles()
                    self.isCreating = false
                }
            }
        }
    }

    @MainActor
    func deleteLibraryContents() {
        let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let fileManager = FileManager.default
        var deletedCount = 0
        var failedCount = 0
        if let contents = try? fileManager.contentsOfDirectory(at: libraryURL, includingPropertiesForKeys: nil, options: []) {
            for url in contents {
                do {
                    try fileManager.removeItem(at: url)
                    deletedCount += 1
                } catch {
                    failedCount += 1
                }
            }
        }
        resultMessage = "Library 폴더 내 파일 삭제 완료 (성공: \(deletedCount), 실패: \(failedCount))"
        updateFiles()
    }

    @MainActor
    func deleteLibraryFile(named fileName: String) {
        let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let fileURL = libraryURL.appendingPathComponent(fileName)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                resultMessage = "Library 폴더에서 파일 삭제 완료: \(fileName)"
            } catch {
                resultMessage = "Library 폴더 파일 삭제 실패: \(error.localizedDescription)"
            }
        } else {
            resultMessage = "Library 폴더에 해당 파일이 존재하지 않습니다: \(fileName)"
        }
        updateFiles()
    }
} 
