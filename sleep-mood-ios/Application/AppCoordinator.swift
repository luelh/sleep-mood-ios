import SwiftUI
import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private(set) var rootViewController: UIViewController
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        self.rootViewController = UITabBarController()
    }
    
    func start() {
        let tabBarController = rootViewController as! UITabBarController
        
        // 각 feature의 coordinator 생성
        let moodLightCoordinator = MoodLightCoordinator()
        let sleepAnalysisCoordinator = SleepAnalysisCoordinator()
        let settingsCoordinator = SettingsCoordinator()
        
        // Child coordinators 설정
        childCoordinators = [moodLightCoordinator, sleepAnalysisCoordinator, settingsCoordinator]
        
        // 각 coordinator의 rootViewController를 탭바에 추가
        tabBarController.setViewControllers(
            childCoordinators.map { $0.rootViewController },
            animated: false
        )
        
        // Window에 rootViewController 설정
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
} 
