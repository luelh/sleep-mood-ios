//
//  AudioListViewModel.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/11/25.
//

import AVFoundation
import Combine
import AsleepSDK
import Foundation

class AudioListViewModel: NSObject, ObservableObject {
    @Published var audioFiles: [AudioFile] = []
    @Published var isLoading = false
    @Published private var currentlyPlayingFileId: UUID?
    private var audioPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category:", error)
        }
    }
    
    struct AudioFile: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let url: URL
        let createdAt: Date
        let duration: TimeInterval
        
        static func == (lhs: AudioFile, rhs: AudioFile) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        var formattedDuration: String {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private let supportedAudioExtensions = ["wav", "m4a"]
    
    func loadAudioFiles(for sessionId: String) {
        isLoading = true
        print("Loading audio files for session:", sessionId)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fileManager = FileManager.default
            guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Failed to get document directory")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            print("Document directory:", documentDirectory.path)
            
            let processedChunksPath = documentDirectory.appendingPathComponent("ProcessedChunks")
            print("ProcessedChunks path:", processedChunksPath.path)
            
            // ProcessedChunks 디렉토리가 없으면 생성
            if !fileManager.fileExists(atPath: processedChunksPath.path) {
                do {
                    try fileManager.createDirectory(at: processedChunksPath, withIntermediateDirectories: true)
                    print("Created ProcessedChunks directory")
                } catch {
                    print("Error creating ProcessedChunks directory:", error)
                }
            }
            
            let sessionPath = processedChunksPath.appendingPathComponent(sessionId)
            print("Session path:", sessionPath.path)
            
            guard fileManager.fileExists(atPath: sessionPath.path) else {
                print("Session directory does not exist")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            do {
                let files = try fileManager.contentsOfDirectory(at: sessionPath,
                                                              includingPropertiesForKeys: [.creationDateKey],
                                                              options: [.skipsHiddenFiles])
                print("Found files:", files)
                
                let audioFiles = try files.compactMap { url -> AudioFile? in
                    let fileExtension = url.pathExtension.lowercased()
                    guard self.supportedAudioExtensions.contains(fileExtension) else {
                        print("Skipping unsupported file:", url.lastPathComponent)
                        return nil
                    }
                    
                    let resourceValues = try url.resourceValues(forKeys: [.creationDateKey])
                    let creationDate = resourceValues.creationDate ?? Date()
                    
                    // Get audio duration
                    guard let audioPlayer = try? AVAudioPlayer(contentsOf: url) else {
                        print("Failed to get audio duration for:", url.lastPathComponent)
                        return nil
                    }
                    let duration = audioPlayer.duration
                    
                    // chunk_0.m4a에서 chunk_0 부분만 추출
                    let fileName = url.deletingPathExtension().lastPathComponent
                    let displayName = fileName.replacingOccurrences(of: "chunk_", with: "코골이 ")
                    
                    return AudioFile(
                        name: displayName,
                        url: url,
                        createdAt: creationDate,
                        duration: duration
                    )
                }
                .sorted { $0.createdAt < $1.createdAt }
                
                print("Processed audio files:", audioFiles.map { $0.name })
                
                DispatchQueue.main.async {
                    self.audioFiles = audioFiles
                    self.isLoading = false
                }
            } catch {
                print("Error loading audio files:", error)
                DispatchQueue.main.async {
                    self.audioFiles = []
                    self.isLoading = false
                }
            }
        }
    }
    
    func isPlaying(_ audioFile: AudioFile) -> Bool {
        return currentlyPlayingFileId == audioFile.id
    }
    
    func togglePlayAudio(_ audioFile: AudioFile) {
        if currentlyPlayingFileId == audioFile.id {
            // 현재 재생 중인 파일을 다시 탭한 경우
            audioPlayer?.stop()
            currentlyPlayingFileId = nil
            audioPlayer = nil
        } else {
            // 새로운 파일을 재생하는 경우
            do {
                // 이전 재생 중인 파일이 있다면 중지
                if audioPlayer != nil {
                    audioPlayer?.stop()
                    audioPlayer = nil
                }
                
                let player = try AVAudioPlayer(contentsOf: audioFile.url)
                player.delegate = self
                player.play()
                audioPlayer = player
                currentlyPlayingFileId = audioFile.id
            } catch {
                print("Error playing audio:", error)
            }
        }
    }
}

extension AudioListViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.currentlyPlayingFileId = nil
            self.audioPlayer = nil
        }
    }
}

