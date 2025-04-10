//
//  PlaybackView.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/10/25.
//

import SwiftUI
import AVFoundation

struct PlaybackView: View {
    @State private var player: AVAudioPlayer?
    @State private var errorMessage: String?
    @State private var isPlaying = false

    var body: some View {
        VStack(spacing: 20) {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                Button(action: {
                    if isPlaying {
                        player?.stop()
                        isPlaying = false
                    } else {
                        player?.play()
                        isPlaying = true
                    }
                }) {
                    Label(isPlaying ? "중지" : "재생", systemImage: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title)
                }
                Text("길이: \(String(format: "%.1f", player?.duration ?? 0))초")
                    .font(.caption)
                    .foregroundColor(.gray)

            }
        }
        .navigationTitle("최근 녹음")
        .onAppear {
            loadLatestRecording()
        }
    }

    private func loadLatestRecording() {
        // 임시 저장 경로의 녹음 파일 URL
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("latest_recording.m4a") // 녹음 시 여기에 저장했다고 가정

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            errorMessage = "최근 녹음이 없습니다."
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: fileURL)
            player?.prepareToPlay()
        } catch {
            errorMessage = "녹음 파일을 재생할 수 없습니다: \(error.localizedDescription)"
        }
    }
}
