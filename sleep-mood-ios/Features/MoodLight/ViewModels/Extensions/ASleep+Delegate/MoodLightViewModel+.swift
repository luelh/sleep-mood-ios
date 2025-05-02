//
//  MoodLightViewModel+.swift
//  sleep-mood-ios
//
//  Created by luelh on 5/2/25.
//

import AVFoundation

extension MoodLightViewModel {
    func saveBufferListAsAAC(buffers: [AVAudioPCMBuffer], format: AVAudioFormat, sessionId: String) {
        guard !buffers.isEmpty else { return }

        let fileManager = FileManager.default
        guard let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Documents 디렉토리를 찾을 수 없습니다.")
            return
        }
        let bSleepDir = docDir.appendingPathComponent("BSleep")
        if !fileManager.fileExists(atPath: bSleepDir.path) {
            do {
                try fileManager.createDirectory(at: bSleepDir, withIntermediateDirectories: true)
                print("BSleep 디렉토리 생성됨: \(bSleepDir.path)")
            } catch {
                print("❌ BSleep 디렉토리 생성 실패: \(error)")
                return
            }
        }
        // 파일명: sessionId가 있으면 sessionId.m4a, 없으면 날짜 기반
        let fileName: String
//        if let sessionId = sessionId, !sessionId.isEmpty {
//            fileName = "\(sessionId).m4a"
//        } else {
        fileName = "Recording_\(ISO8601DateFormatter().string(from: Date())).m4a"
//        }
        let outputURL = bSleepDir.appendingPathComponent(fileName)

        do {
            let outputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: format.sampleRate,
                AVNumberOfChannelsKey: format.channelCount,
                AVEncoderBitRateKey: 64000
            ]

            let file = try AVAudioFile(forWriting: outputURL,
                                       settings: outputSettings,
                                       commonFormat: .pcmFormatFloat32,
                                       interleaved: true)

            for buffer in buffers {
                try file.write(from: buffer)
            }

            print("🎧 Saved AAC at: \(outputURL)")
        } catch {
            print("❌ Failed to save AAC: \(error)")
        }
    }
}
