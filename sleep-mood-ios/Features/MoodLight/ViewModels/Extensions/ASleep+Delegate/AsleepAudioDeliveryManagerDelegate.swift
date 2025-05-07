//
//  AsleepAudioDeliveryManagerDelegate.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/30/25.
//

import Foundation
import AsleepSDK
import AVFoundation

extension MoodLightViewModel: AsleepAudioDeliveryManagerDelegate {
    func deliveryAudio(didReceiveRawBuffer buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        if self.audioFormat == nil {
            self.audioFormat = buffer.format
            print("🎵 Audio format initialized:", buffer.format)
        }
        if self.isRecording {
            // 실시간 파일 저장 방식
            if audioFile == nil {
                // 파일 경로 생성 (예시: sessionId가 있으면 sessionId.m4a, 없으면 날짜 기반)
                let fileManager = FileManager.default
                guard let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let bSleepDir = docDir.appendingPathComponent("BSleep")
                if !fileManager.fileExists(atPath: bSleepDir.path) {
                    try? fileManager.createDirectory(at: bSleepDir, withIntermediateDirectories: true)
                }
                let fileName: String
                if let sessionId = self.sessionId, !sessionId.isEmpty {
                    fileName = "\(sessionId)_realtime.m4a"
                } else {
                    fileName = "Recording_\(ISO8601DateFormatter().string(from: Date()))_realtime.m4a"
                }
                let outputURL = bSleepDir.appendingPathComponent(fileName)
                let outputSettings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVSampleRateKey: buffer.format.sampleRate,
                    AVNumberOfChannelsKey: buffer.format.channelCount,
                    AVEncoderBitRateKey: 64000
                ]
                do {
                    audioFile = try AVAudioFile(forWriting: outputURL, settings: outputSettings, commonFormat: .pcmFormatFloat32, interleaved: true)
                    print("[실시간] 오디오 파일 생성: \(outputURL)")
                } catch {
                    print("[실시간] 오디오 파일 생성 실패: \(error)")
                    return
                }
            }
            do {
                try audioFile?.write(from: buffer)
                // print("[실시간] 버퍼 저장됨")
            } catch {
                print("[실시간] 버퍼 저장 실패: \(error)")
            }
        }
    }
}
