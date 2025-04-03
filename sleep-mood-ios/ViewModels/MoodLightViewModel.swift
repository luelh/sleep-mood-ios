import Foundation
import AsleepSDK
import SwiftUI

class MoodLightViewModel: ObservableObject {
    
    private(set) var trackingManager: Asleep.SleepTrackingManager?
    private(set) var reports: Asleep.Reports?
    
    @Published private(set) var config: Asleep.Config?
    
    
    @Published var userId: String {
        didSet {
            UserDefaults.standard.set(userId, forKey: "sleepmood+userId")
        }
    }

    @Published var apiKey: String
    @Published var baseUrl: String {
        didSet {
            UserDefaults.standard.set(baseUrl, forKey: "sleepmood+baseurl")
        }
    }

    @Published var callbackUrl: String {
        didSet {
            UserDefaults.standard.set(callbackUrl, forKey: "sleepmood+callbackurl")
        }
    }
    
    
    @Published var sessionId: String?
    @Published var sequenceNumber: Int?

    @Published var error: String?
    
    @Published var isLightOn = false
    @Published var lightColor: Color = .yellow.opacity(0.5)
    
    @Published var isTracking = false
    @Published var startTime: Date?
    
    init() {
        self.userId = UserDefaults.standard.string(forKey: "sleepmood+userId") ?? ""
        self.apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
        self.baseUrl = UserDefaults.standard.string(forKey: "sleepmood+baseurl") ?? ""
        self.callbackUrl = UserDefaults.standard.string(forKey: "sleepmood+callbackurl") ?? ""
    }

    func toggleLight() {
//        withAnimation(.easeInOut(duration: 0.3)) {
//            isLightOn.toggle()
//        }
        isLightOn.toggle()
        
        if isTracking {
            stopTracking()
        } else {
            startTracking(hasConfig: config != nil)
        }
    }
    
    private func stopTracking() {
        trackingManager?.stopTracking()
        initReport()
    }
    
    private func startTracking(hasConfig: Bool) {
        sessionId = ""
        if hasConfig {
            trackingManager?.startTracking()
        } else {
            initAsleepConfig(apiKey: apiKey, userId: userId, baseUrl: .init(string: baseUrl), callbackUrl: .init(string: callbackUrl))
        }
        startTime = Date()
        sequenceNumber = nil
    }
    
    func initAsleepConfig(apiKey: String, userId: String, baseUrl: URL?, callbackUrl: URL?) {
        Asleep.initAsleepConfig(apiKey: apiKey, userId: userId.isEmpty ? nil : userId, baseUrl: baseUrl, callbackUrl: callbackUrl, delegate: self)
        Asleep.setDebugLoggerDelegate(self)
    }
}






// MARK: - AsleepSDK Delegate - AsleepConfigDelegate

extension MoodLightViewModel: AsleepConfigDelegate {
    func userDidJoin(userId: String, config: AsleepSDK.Asleep.Config) {
        Task { @MainActor in
            self.config = config
            self.userId = userId
            initSleepTrackingManager()
            trackingManager?.startTracking()
        }
    }
    
    func initSleepTrackingManager() {
        guard let config else { return }
        trackingManager = Asleep.createSleepTrackingManager(config: config, delegate: self)
    }

    func initReport() {
        guard let config else { return }
        reports = Asleep.createReports(config: config)
    }
    
    func didFailUserJoin(error: AsleepSDK.Asleep.AsleepError) {
        print("Failed user join with the error:", error)
    }
    
    func userDidDelete(userId: String) {
        print("Deleted user id:", userId)
    }
}


// MARK: - AsleepSDK Delegate - AsleepSleepTrackingManagerDelegate

extension MoodLightViewModel: AsleepSleepTrackingManagerDelegate {
    func didCreate() {
        Task { @MainActor in
            self.isTracking = true
            self.error = nil
        }
    }
    
    func didUpload(sequence: Int) {
        Task { @MainActor in
            self.sequenceNumber = sequence
        }
    }
    
    func didClose(sessionId: String) {
        Task { @MainActor in
            self.isTracking = false
            self.sessionId = sessionId
        }
    }
    
    func didFail(error: AsleepSDK.Asleep.AsleepError) {
        switch error {
        case let .httpStatus(code, _, message) where code == 403 || code == 404:
            Task { @MainActor in
                self.isTracking = false
                self.error = String("\(code): \(message ?? "")")
            }
            print("Stopped sleep tracking with the error: ", error)
        default:
            print("Failed tracking with the error: ", error)
        }
    }
    
    func didInterrupt() {
        print("Tracking is interrupted")
    }
    
    func didResume() {
        print("Tracking is resumed")
    }
    
    func micPermissionWasDenied() {
        Task { @MainActor in
            self.isTracking = false
        }
        print(micPermissionWasDenied)
    }
    
    func analysing(session: AsleepSDK.Asleep.Model.Session) {
        print("Analysis result:", session)
    }
}


// MARK: - AsleepSDK Delegate - AsleepDebugLoggerDelegate

extension MoodLightViewModel: AsleepDebugLoggerDelegate {
    func didPrint(message: String) {
    }
}
