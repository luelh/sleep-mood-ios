//
//  SleepSession.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/3/25.
//
import SwiftUI

struct SleepSession: Identifiable {
    let id: String
    let date: Date
    let duration: TimeInterval
    let quality: Double
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    var qualityPercentage: String {
        return String(format: "%.1f%%", quality * 100)
    }
}
