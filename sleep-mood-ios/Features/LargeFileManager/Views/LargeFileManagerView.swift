import SwiftUI

struct LargeFileManagerView: View {
    @ObservedObject var viewModel: LargeFileManagerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("대용량 파일 테스트")
                .font(.title2)
                .bold()
                .padding(.top, 24)
            
            Text("남은 저장 공간: \(viewModel.freeSpaceString)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("총 대용량 파일 용량: \(viewModel.totalFilesSizeString)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.createLargeFile()
                }) {
                    Text("대용량 파일 생성")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isCreating || viewModel.isBatchCreating ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isCreating || viewModel.isBatchCreating)
                Button(action: {
                    Task { await viewModel.deleteAllFiles() }
                }) {
                    Text("전체 삭제")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isBatchCreating ? Color.gray : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.files.isEmpty || viewModel.isBatchCreating)
            }
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                Button(action: {
                    Task { await viewModel.startBatchCreateFiles(count: 20) }
                }) {
                    Text("대용량 파일 20개 생성")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isBatchCreating ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isBatchCreating || viewModel.isCreating)
                Button(action: {
                    Task { await viewModel.stopBatchCreateFiles() }
                }) {
                    Text("중단")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isBatchCreating ? Color.orange : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isBatchCreating)
            }
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.createSmallFile()
                }) {
                    Text("50MB 파일 생성")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isCreating || viewModel.isBatchCreating ? Color.gray : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isCreating || viewModel.isBatchCreating)
                Button(action: {
                    viewModel.createTinyFile()
                }) {
                    Text("5MB 파일 생성")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isCreating || viewModel.isBatchCreating ? Color.gray : Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isCreating || viewModel.isBatchCreating)
                Button(action: {
                    viewModel.deleteLibraryContents()
                }) {
                    Text("Library 폴더 비우기")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isCreating || viewModel.isBatchCreating ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isCreating || viewModel.isBatchCreating)
                Button(action: {
                    viewModel.deleteLibraryFile(named: "c_file4.bin")
                }) {
                    Text("c_file4.bin 삭제")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isCreating || viewModel.isBatchCreating ? Color.gray : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isCreating || viewModel.isBatchCreating)
            }
            .padding(.horizontal)
            
            if let message = viewModel.resultMessage {
                Text(message)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            
            Divider().padding(.vertical, 8)
            
            if viewModel.files.isEmpty {
                Text("생성된 대용량 파일이 없습니다.")
                    .foregroundColor(.secondary)
                    .padding(.top, 32)
                Spacer()
            } else {
                List {
                    ForEach(viewModel.files) { file in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(file.id)
                                    .font(.caption)
                                    .lineLimit(1)
                                Text(ByteCountFormatter.string(fromByteCount: Int64(file.size), countStyle: .file))
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                Task { await viewModel.deleteFile(file) }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .disabled(viewModel.isBatchCreating)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("대용량 파일")
        .onAppear {
            viewModel.updateFiles()
        }
    }
}

#Preview {
    LargeFileManagerView(viewModel: LargeFileManagerViewModel())
} 
