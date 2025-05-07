//
//  AudioListView.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/11/25.
//

// AudioListView.swift
//import SwiftUI
//
//struct AudioListView: View {
//    @StateObject private var viewModel = AudioListViewModel()
//    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(Array(viewModel.audioChunks.enumerated()), id: \.element.id) { index, chunk in
//                    AudioChunkRow(
//                        chunk: chunk,
//                        isPlaying: viewModel.currentlyPlayingIndex == index,
//                        onTap: {
//                            if viewModel.currentlyPlayingIndex == index {
//                                viewModel.stopPlayback()
//                            } else {
//                                viewModel.playAudioChunk(at: index)
//                            }
//                        }
//                    )
//                }
//                .onDelete { indexSet in
//                    indexSet.forEach { viewModel.deleteChunk(at: $0) }
//                }
//            }
//            .navigationTitle("Recorded Audio")
//            .toolbar {
//                EditButton()
//            }
//        }
//    }
//}
//
//struct AudioChunkRow: View {
//    let chunk: AudioChunk
//    let isPlaying: Bool
//    let onTap: () -> Void
//    
//    var body: some View {
//        Button(action: onTap) {
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("Chunk #\(chunk.sequence)")
//                        .font(.headline)
//                    Text("Start: \(chunk.formattedStartTime)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Text("Duration: \(chunk.formattedDuration)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//                
//                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                    .font(.title)
//                    .foregroundColor(isPlaying ? .blue : .gray)
//            }
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}
//
//#Preview {
//    AudioListView()
//}
