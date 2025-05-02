import SwiftUI
import AVFoundation

struct BSleepAudioListView: View {
    @State private var audioFiles: [AudioFile] = []
    @State private var player: AVAudioPlayer?
    @State private var playingFile: URL?
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    
    struct AudioFile: Identifiable {
        let id = UUID()
        let url: URL
        let name: String
        let createdAt: Date
    }
    
    var body: some View {
        List(audioFiles) { file in
            Button(action: {
                playAudio(file: file)
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(file.name)
                        Text("\(file.createdAt, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if playingFile == file.url {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("BSleep 오디오")
        .onAppear {
            setupAudioSession()
            loadAudioFiles()
        }
        .onDisappear {
            cleanupAudioSession()
        }
        .alert("오류", isPresented: $showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "알 수 없는 오류가 발생했습니다.")
        }
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            print("❌ AVAudioSession 설정 실패:", error)
        }
    }
    
    private func cleanupAudioSession() {
        player?.stop()
        player = nil
        playingFile = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("❌ AVAudioSession 비활성화 실패:", error)
        }
    }
    
    private func loadAudioFiles() {
        audioFiles = fetchBSleepAudioFiles()
    }
    
    private func playAudio(file: AudioFile) {
        if playingFile == file.url {
            player?.stop()
            player = nil
            playingFile = nil
            return
        }
        do {
            // 이전 재생 중인 오디오 정리
            player?.stop()
            player = nil
            
            // 새로운 오디오 재생 준비
            player = try AVAudioPlayer(contentsOf: file.url)
            guard let player = player else {
                throw NSError(domain: "BSleepAudio", code: -1, userInfo: [NSLocalizedDescriptionKey: "플레이어 초기화 실패"])
            }
            
            player.prepareToPlay()
            player.play()
            playingFile = file.url
            
        } catch {
            print("❌ 오디오 재생 실패:", error)
            errorMessage = "오디오 재생 실패: \(error.localizedDescription)"
            showError = true
            
            // 에러 발생 시 상태 초기화
            player = nil
            playingFile = nil
        }
    }
    
    private func fetchBSleepAudioFiles() -> [AudioFile] {
        let fileManager = FileManager.default
        guard let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "Documents 디렉토리를 찾을 수 없습니다."
            showError = true
            return []
        }
        let bSleepDir = docDir.appendingPathComponent("BSleep")
        guard fileManager.fileExists(atPath: bSleepDir.path) else { return [] }
        
        var audioFiles: [AudioFile] = []
        
        // 1. BSleep 폴더 내 파일 추가
        if let files = try? fileManager.contentsOfDirectory(at: bSleepDir, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles) {
            let filtered = files.filter { ["aac", "m4a", "wav"].contains($0.pathExtension.lowercased()) }
            for url in filtered {
                let name = url.lastPathComponent
                let createdAt = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date()
                audioFiles.append(AudioFile(url: url, name: name, createdAt: createdAt))
            }
        }
        
        // 2. 하위 폴더 순회
        if let sessionDirs = try? fileManager.contentsOfDirectory(at: bSleepDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            for sessionDir in sessionDirs where sessionDir.hasDirectoryPath {
                if let files = try? fileManager.contentsOfDirectory(at: sessionDir, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles) {
                    let filtered = files.filter { ["aac", "m4a", "wav"].contains($0.pathExtension.lowercased()) }
                    for url in filtered {
                        let name = url.lastPathComponent
                        let createdAt = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date()
                        audioFiles.append(AudioFile(url: url, name: name, createdAt: createdAt))
                    }
                }
            }
        }
        return audioFiles.sorted { $0.createdAt > $1.createdAt }
    }
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return df
    }
} 