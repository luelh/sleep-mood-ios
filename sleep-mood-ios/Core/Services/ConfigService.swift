//
//  ConfigService.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/4/25.
//

import Foundation
import AsleepSDK

class ConfigService: ObservableObject {
    static let shared = ConfigService()
    
    @Published private(set) var config: Asleep.Config?
    
    var userId: String {
        get {
            UserDefaults.standard.string(forKey: "sleepmood+userId") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "sleepmood+userId")
        }
    }
    
    var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
    }
    
    var baseUrl: String {
        UserDefaults.standard.string(forKey: "sleepmood+baseurl") ?? ""
    }
    
    var callbackUrl: String {
        UserDefaults.standard.string(forKey: "sleepmood+callbackurl") ?? ""
    }
    
    private init() {}
    
    func initAsleepConfig() {
        print("api key info.plist:", Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? "")
        print("api key:", apiKey)
        print("Initializing Asleep Config with userId:", userId.isEmpty ? nil : userId)
        guard !apiKey.isEmpty else { return }
        Asleep.initAsleepConfig(
            apiKey: apiKey,
            userId: userId.isEmpty ? nil : userId,
            baseUrl: URL(string: baseUrl),
            callbackUrl: URL(string: callbackUrl),
            delegate: self
        )
    }
    
    func createReports() -> Asleep.Reports? {
        guard let config = config else {
            initAsleepConfig()
            return nil
        }
        return Asleep.createReports(config: config)
    }
    
    func createSleepTrackingManager(config: Asleep.Config,
                                    delegate: AsleepSleepTrackingManagerDelegate) -> Asleep.SleepTrackingManager? {
//        
        return Asleep.createSleepTrackingManager(config: config, delegate: delegate)
    }
}

// MARK: - AsleepSDK Delegate
extension ConfigService: AsleepConfigDelegate {
    func userDidJoin(userId: String, config: AsleepSDK.Asleep.Config) {
        Task { @MainActor in
            print("UserDidJoin - Setting config and userId:", userId)
            self.config = config
            self.userId = userId
            NotificationCenter.default.post(name: .asleepConfigDidUpdate, object: nil)
        }
    }
    
    func didFailUserJoin(error: AsleepSDK.Asleep.AsleepError) {
        print("Failed user join with the error:", error)
    }
    
    func userDidDelete(userId: String) {
        print("Deleted user id:", userId)
        if userId == self.userId {
            self.userId = ""
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let asleepConfigDidUpdate = Notification.Name("asleepConfigDidUpdate")
}
