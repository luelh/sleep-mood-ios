import Foundation
import AsleepSDK
import SwiftUI

class MoodLightViewModel: ObservableObject {
    
    
    // MARK: - Dependencies
    
    private let configService = ConfigService.shared
    
    
    // MARK: - private properties
    
    private(set) var trackingManager: Asleep.SleepTrackingManager?
    private let colorKey = "sleepmood+lightColor"
    
    
    // MARK: - published state
    
    @Published var sessionId: String?
    @Published var sequenceNumber: Int?
    @Published var error: String?
    @Published var isLightOn = false
    @Published var isTracking = false
    @Published var lightColor: RGBAColor = RGBAColor(red: 1, green: 1, blue: 0, alpha: 0.5)

    
    
    // MARK: - initialize
    
    init() {
        loadLightColor()
        NotificationCenter.default.addObserver(self, selector: #selector(configDidUpdate), name: .asleepConfigDidUpdate, object: nil)
        if let config = configService.config {
            trackingManager = configService.createSleepTrackingManager(config: config, delegate: self)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func configDidUpdate() {
        if let config = configService.config {
            trackingManager = configService.createSleepTrackingManager(config: config, delegate: self)
        }
    }
    
    
    // MARK: - private method
    
    private func initSleepTrackingManager() {
        guard let config = configService.config else { return }
        trackingManager = configService.createSleepTrackingManager(config: config, delegate: self)
    }
    
    private func stopTracking() {
        print("-- stopTracking --")
        isTracking = false
        isLightOn = false
        trackingManager?.stopTracking()
    }
    
    private func startTracking(hasConfig: Bool) {
        sessionId = ""
        if hasConfig {
            print("-- startTracking --")
            trackingManager?.startTracking()
            isTracking = true
            isLightOn = true
        } else {
            print("-- startTracking initAsleepConfig --")
            configService.initAsleepConfig()
        }
        sequenceNumber = nil
    }
    
    private func loadLightColor() {
        if let data = UserDefaults.standard.data(forKey: colorKey),
           let rgba = try? JSONDecoder().decode(RGBAColor.self, from: data) {
            lightColor = rgba
        }
    }
    
    
    // MARK: - internal method
    
    func toggleLight() {
        if isTracking {
            stopTracking()
        } else {
            startTracking(hasConfig: configService.config != nil)
        }
    }
    
    func setLight() {
        isLightOn.toggle()
    }

}
