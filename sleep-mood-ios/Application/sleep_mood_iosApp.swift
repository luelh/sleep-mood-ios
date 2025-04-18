//
//  sleep_mood_iosApp.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/3/25.
//

import SwiftUI
import AsleepSDK

@main
struct sleep_mood_iosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Asleep SDK with OnDevice functionality
        Asleep.setup(
            apiKey: ConfigService.shared.apiKey,
            enableODA: true,
            delegate: ConfigService.shared
        )
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        coordinator = AppCoordinator(window: window)
        coordinator?.start()
        
        return true
    }
}
