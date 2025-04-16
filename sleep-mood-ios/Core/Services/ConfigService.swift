//
//  ConfigService.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/4/25.
//

import Foundation
import AsleepSDK

// Custom structure to store config data
private struct ConfigData: Codable {
    let userId: String
    let apiKey: String
    let baseUrl: String?
    let callbackUrl: String?
    
    init(from config: Asleep.Config, userId: String, apiKey: String) {
        self.userId = userId
        self.apiKey = apiKey
        self.baseUrl = nil  // AsleepSDK에서 관리하므로 저장할 필요 없음
        self.callbackUrl = nil  // AsleepSDK에서 관리하므로 저장할 필요 없음
    }
}

class ConfigService: ObservableObject {
    static let shared = ConfigService()
    
    private let configKey = "sleepmood+config"
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
    
    private init() {
        loadSavedConfig()
    }
    
    private func loadSavedConfig() {
        if let savedData = UserDefaults.standard.data(forKey: configKey),
           let configData = try? JSONDecoder().decode(ConfigData.self, from: savedData) {
            // ConfigData가 있다면 SDK 초기화
            initAsleepConfig(withSavedData: configData)
        }
    }
    
    private func saveConfigData(userId: String, apiKey: String) {
        guard let config = config else { return }
        let configData = ConfigData(from: config, userId: userId, apiKey: apiKey)
        if let encodedData = try? JSONEncoder().encode(configData) {
            UserDefaults.standard.set(encodedData, forKey: configKey)
        }
    }
    
    private func initAsleepConfig(withSavedData configData: ConfigData) {
        Asleep.initAsleepConfig(
            apiKey: configData.apiKey,
            userId: configData.userId,
            baseUrl: URL(string: baseUrl),
            callbackUrl: URL(string: callbackUrl),
            delegate: self
        )
    }
    
    func initAsleepConfig(forceNew: Bool = false) {
        print("api key info.plist:", Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? "")
        print("api key:", apiKey)
        print("Initializing Asleep Config with userId:", userId.isEmpty ? nil : userId)
        
        guard !apiKey.isEmpty else { return }
        
        // If we have a saved config and don't need to force new, skip initialization
        if !forceNew, config != nil {
            print("Using existing config, skipping initialization")
            return
        }
        
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
            print("No config available for creating reports")
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
            self.saveConfigData(userId: userId, apiKey: apiKey)
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
