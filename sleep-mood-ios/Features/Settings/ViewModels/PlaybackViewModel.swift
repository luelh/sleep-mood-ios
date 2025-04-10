//
//  PlaybackViewModel.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/10/25.
//

import Foundation
import AsleepSDK
import AVFAudio
import Combine

final class PlaybackViewModel {
    
    // MARK: - Properties
    
    private var bufferedChunks: [Data] = []
    private var player: AVAudioPlayer?
    
    let recorderDelegate: AsleepRecordingDelegate?
    
    var recordManager: Asleep.Recorder?
    
    init() {
        recorderDelegate.delegate = self
    }
    
    // MARK: - Public Methods
    
    /// 수신된 오디오 청크들을 합쳐 파일로 저장하고 재생
    func playLatestRecording() {
        guard let fileURL = saveMergedRecordingFile() else {
            print("파일 저장 실패로 재생 불가")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: fileURL)
            player?.prepareToPlay()
            player?.play()
            print("재생 시작: \(fileURL.lastPathComponent)")
        } catch {
            print("재생 실패: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// 버퍼된 모든 오디오 청크를 하나의 파일로 저장
    private func saveMergedRecordingFile() -> URL? {
        let fullData = bufferedChunks.reduce(Data(), +)
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("latest_recording.m4a")

        do {
            try fullData.write(to: fileURL)
            print("병합된 녹음 저장 완료: \(fileURL)")
            return fileURL
        } catch {
            print("저장 실패: \(error)")
            return nil
        }
    }
    
    /// 청크 단위 파일 저장 (디버깅 또는 개별 확인용)
    private func saveChunkToTempFile(data: Data, sequence: Int) {
        let filename = "recording_chunk_\(sequence).aac"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: url)
            print("청크 저장됨: \(url)")
        } catch {
            print("청크 저장 실패: \(error)")
        }
    }
}

extension PlaybackViewModel: AsleepRecordingDelegate {
    
    func recordedData(_ data: Data, sequence: Int) {
        let copiedData = Data(data) // 안전하게 복사
        bufferedChunks.append(copiedData)
        saveChunkToTempFile(data: copiedData, sequence: sequence)
    }
    
    func didFail(error: AsleepSDK.Asleep.AsleepError) {
        print("녹음 실패: \(error)")
    }
    
    func didInterrupt() {
        print("녹음 일시중지됨")
    }
    
    func didResume() {
        print("녹음 다시 시작됨")
    }
    
    func micPermissionWasDenied() {
        print("마이크 권한 거부됨")
    }
}
