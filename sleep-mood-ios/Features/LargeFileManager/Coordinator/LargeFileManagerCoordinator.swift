import SwiftUI

class LargeFileManagerCoordinator: ObservableObject {
    @Published var viewModel = LargeFileManagerViewModel()
    
    func makeView() -> some View {
        LargeFileManagerView(viewModel: viewModel)
    }
} 