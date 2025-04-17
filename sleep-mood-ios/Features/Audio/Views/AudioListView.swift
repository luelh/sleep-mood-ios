//
//  AudioListView.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/11/25.
//

import SwiftUI
import AsleepSDK

struct AudioListView: View {
    let sessionId: String
    @StateObject private var viewModel = AudioListViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.audioFiles.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "waveform.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("녹음된 오디오가 없습니다")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("이 수면 기록에서 코골이가 감지되지 않았습니다")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding()
            } else {
                List {
                    ForEach(viewModel.audioFiles) { audioFile in
                        AudioRowView(audioFile: audioFile, isPlaying: viewModel.isPlaying(audioFile)) {
                            viewModel.togglePlayAudio(audioFile)
                        }
                    }
                }
            }
        }
        .navigationTitle("코골이 녹음")
        .onAppear {
            viewModel.loadAudioFiles(for: sessionId)
        }
    }
}

struct AudioRowView: View {
    let audioFile: AudioListViewModel.AudioFile
    let isPlaying: Bool
    let onTap: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(audioFile.name)
                        .font(.headline)
                    
                    HStack {
                        Text(dateFormatter.string(from: audioFile.createdAt))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("(\(audioFile.formattedDuration))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    NavigationView {
        AudioListView(sessionId: "test-session")
    }
}
