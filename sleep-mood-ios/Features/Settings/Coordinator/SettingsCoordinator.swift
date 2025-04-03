import SwiftUI

class SettingsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private(set) var rootViewController: UIViewController
    
    init() {
        let view = SettingsView()
        rootViewController = UIHostingController(rootView: view)
        rootViewController.tabBarItem = UITabBarItem(
            title: "설정",
            image: UIImage(systemName: "gear"),
            tag: 2
        )
    }
    
    func start() {
        // 초기 설정이나 추가 네비게이션 로직
    }
} 