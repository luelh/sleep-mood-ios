//
//  AsleepSleepTrackingManagerDelegate.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/4/25.
//

import Foundation
import AsleepSDK

extension MoodLightViewModel: AsleepSleepTrackingManagerDelegate {
    func didCreate() {
        Task { @MainActor in
            self.isTracking = true
            self.error = nil
            
            self.bufferList = []
            self.isRecording = true
            self.recordingStartTime = Date()
        }
    }
    
    func didUpload(sequence: Int) {
        Task { @MainActor in
            self.sequenceNumber = sequence
        }
    }
    
    func didClose(sessionId: String) {
        print("🔔 didClose called with sessionId:", sessionId)
        Task { @MainActor in
            self.isTracking = false
            self.isLightOn = false
            self.sessionId = sessionId
            
            self.isRecording = false

            print("📝 Saving audio - format exists: \(self.audioFormat != nil), buffers count: \(self.bufferList.count)")
            if let format = self.audioFormat {
                saveBufferListAsAAC(buffers: self.bufferList, format: format, sessionId: sessionId)
                print("✅ Audio save attempted for session:", sessionId)
            } else {
                print("❌ Audio format is nil")
            }

            self.bufferList = []
        }
    }
    
    func didFail(error: AsleepSDK.Asleep.AsleepError) {
        switch error {
        case let .httpStatus(code, _, message) where code == 403 || code == 404:
            Task { @MainActor in
                self.isTracking = false
                self.isLightOn = false
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
            self.isLightOn = false
        }
        print("Mic permission was denied")
    }
    
    func analysing(session: AsleepSDK.Asleep.Model.Session) {
        print("Analysis result:", session)
    }
}
