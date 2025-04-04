import Foundation
import AsleepSDK
import SwiftUI

class MoodLightViewModel: ObservableObject {
    private let configService = ConfigService.shared
    
    private(set) var trackingManager: Asleep.SleepTrackingManager?
    private(set) var reports: Asleep.Reports?
    
    // MARK: - config를 만들기 위한 기본 값
    private(set) var userId: String {
        didSet {
            UserDefaults.standard.set(userId, forKey: "sleepmood+userId")
        }
    }

    private var baseUrl: String {
        didSet {
            UserDefaults.standard.set(baseUrl, forKey: "sleepmood+baseurl")
        }
    }

    private var callbackUrl: String {
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
        self.baseUrl = UserDefaults.standard.string(forKey: "sleepmood+baseurl") ?? ""
        self.callbackUrl = UserDefaults.standard.string(forKey: "sleepmood+callbackurl") ?? ""
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(configDidUpdate),
            name: .asleepConfigDidUpdate,
            object: nil
        )
    }
    
    @objc private func configDidUpdate() {
        initSleepTrackingManager()
        trackingManager?.startTracking()
    }

    func toggleLight() {
        isLightOn.toggle()
        
        if isTracking {
            stopTracking()
        } else {
            startTracking(hasConfig: configService.config != nil)
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
            configService.initAsleepConfig()  // ConfigService를 통해 config 초기화
        }
        startTime = Date()
        sequenceNumber = nil
    }
    
    func initSleepTrackingManager() {
        trackingManager = configService.createSleepTrackingManager(delegate: self)
    }

    func initReport() {
        reports = configService.createReports()
    }
}

// MARK: - AsleepSDK Delegate - AsleepConfigDelegate
extension MoodLightViewModel: AsleepConfigDelegate {
    func userDidJoin(userId: String, config: AsleepSDK.Asleep.Config) {
        Task { @MainActor in
            print("UserDidJoin - Saving userId")
            self.userId = userId
            initSleepTrackingManager()
            trackingManager?.startTracking()
        }
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
