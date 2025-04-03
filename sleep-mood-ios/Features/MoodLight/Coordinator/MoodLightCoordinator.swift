import SwiftUI
import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var rootViewController: UIViewController { get }
    func start()
}

class MoodLightCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private(set) var rootViewController: UIViewController
    private let viewModel: MoodLightViewModel
    
    init() {
        self.viewModel = MoodLightViewModel()
        let view = MoodLightView()
            .environmentObject(viewModel)
        
        rootViewController = UIHostingController(rootView: view)
        rootViewController.tabBarItem = UITabBarItem(
            title: "무드등",
            image: UIImage(systemName: "lightbulb"),
            tag: 0
        )
    }
    
    func start() {
        // 초기 설정이나 추가 네비게이션 로직
    }
} 