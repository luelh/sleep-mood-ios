import Foundation
import AsleepSDK
import SwiftUI
import AVFoundation

class MoodLightViewModel: ObservableObject {
    
    
    // MARK: - Dependencies
    
    private let configService = ConfigService.shared
    
    
    // MARK: - private properties
    
    private(set) var trackingManager: Asleep.SleepTrackingManager?
    private let colorKey = "sleepmood+lightColor"
    
    internal var bufferList: [AVAudioPCMBuffer] = []
    internal var isRecording: Bool = false
    internal var audioFormat: AVAudioFormat?
    internal var recordingStartTime: Date?
    
    
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
            trackingManager?.setDeliveryDelegate(self)
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func configDidUpdate() {
        if let config = configService.config {
            trackingManager = configService.createSleepTrackingManager(config: config, delegate: self)
            trackingManager?.setDeliveryDelegate(self)
        }
    }
    
    
    // MARK: - private method
    
    private func initSleepTrackingManager() {
        guard let config = configService.config else { return }
        trackingManager = configService.createSleepTrackingManager(config: config, delegate: self)
        trackingManager?.setDeliveryDelegate(self)
    }
    
    private func stopTracking() {
        isTracking = false
        isLightOn = false
        trackingManager?.stopTracking()
    }
    
    private func startTracking(hasConfig: Bool) {
        sessionId = ""
        if hasConfig {
            trackingManager?.startTracking()
            isTracking = true
            isLightOn = true
        } else {
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
