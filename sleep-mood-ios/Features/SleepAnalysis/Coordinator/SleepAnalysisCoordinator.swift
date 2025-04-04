import SwiftUI
import UIKit

class SleepAnalysisCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private(set) var rootViewController: UIViewController
    private let viewModel: SleepAnalysisViewModel
    
    init() {
        self.viewModel = SleepAnalysisViewModel()
        let view = SleepAnalysisView()
            .environmentObject(viewModel)
        
        rootViewController = UIHostingController(rootView: view)
        rootViewController.tabBarItem = UITabBarItem(
            title: "수면분석",
            image: UIImage(systemName: "bed.double"),
            tag: 1
        )
    }
    
    func start() {
        // 초기 설정이나 추가 네비게이션 로직
    }
} 