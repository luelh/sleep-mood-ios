//
//  sleep_mood_iosApp.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/3/25.
//

import SwiftUI
import AsleepSDK

@main
struct sleep_mood_iosApp: App {
    @StateObject private var asleepManager = AsleepManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(asleepManager)
        }
    }
}

class AsleepManager: ObservableObject {
    @Published var userId: String = ""
    @Published var lightColor: Color = .yellow.opacity(0.5)
    @Published var sessions: [SleepSession] = []
    
    private var asleepSDK: AsleepSDK?
    
    init() {
        // AsleepSDK 초기화
        do {
            asleepSDK = try AsleepSDK()
            // SDK 초기화 성공 시 사용자 ID 설정
            if let sdk = asleepSDK {
                userId = sdk.getUserId()
                loadSessions()
            }
        } catch {
            print("AsleepSDK 초기화 실패: \(error)")
        }
    }
    
    func loadSessions() {
        // 수면 세션 데이터 로드
        guard let sdk = asleepSDK else { return }
        
        do {
            let sleepData = try sdk.getSleepData()
            sessions = sleepData.map { data in
                SleepSession(
                    id: data.sessionId,
                    date: data.startTime,
                    duration: data.duration,
                    quality: data.quality
                )
            }
        } catch {
            print("수면 데이터 로드 실패: \(error)")
        }
    }
    
    func startSleepAnalysis() {
        // 수면 분석 시작
        guard let sdk = asleepSDK else { return }
        
        do {
            try sdk.startAnalysis()
        } catch {
            print("수면 분석 시작 실패: \(error)")
        }
    }
    
    func stopSleepAnalysis() {
        // 수면 분석 중지
        guard let sdk = asleepSDK else { return }
        
        do {
            try sdk.stopAnalysis()
            loadSessions() // 새로운 세션 데이터 로드
        } catch {
            print("수면 분석 중지 실패: \(error)")
        }
    }
}

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
