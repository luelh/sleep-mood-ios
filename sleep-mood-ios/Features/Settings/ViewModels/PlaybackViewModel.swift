//
//  PlaybackViewModel.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/10/25.
//

import Foundation
import AsleepSDK
import AVFAudio
import Combine

final class PlaybackViewModel {
    
    // MARK: - Properties
    
    private var bufferedChunks: [Data] = []
    private var player: AVAudioPlayer?
    
    init() {
        
    }
}
