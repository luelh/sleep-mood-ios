//
//  AsleepAudioDeliveryManagerDelegate.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/30/25.
//

import Foundation
import AsleepSDK
import AVFoundation

extension MoodLightViewModel: AsleepAudioDeliveryManagerDelegate {
    func deliveryAudio(didReceiveRawBuffer buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        if self.audioFormat == nil {
            self.audioFormat = buffer.format
            print("🎵 Audio format initialized:", buffer.format)
        }
        if self.isRecording {
            self.bufferList.append(buffer)
            print("🎵 Buffer added, total buffers:", self.bufferList.count)
        }
    }
}
