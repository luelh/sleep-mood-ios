//
//  ContentView.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var moodLightViewModel = MoodLightViewModel()
    @StateObject private var sleepAnalysisViewModel = SleepAnalysisViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                MoodLightView()
            }
            .tabItem {
                Image(systemName: "lightbulb")
                Text("무드등")
            }
            .environmentObject(moodLightViewModel)
            
            NavigationView {
                SleepAnalysisView()
            }
            .tabItem {
                Image(systemName: "bed.double")
                Text("수면분석")
            }
            .environmentObject(sleepAnalysisViewModel)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("설정")
            }
            
            MainTabView()
                .tabItem {
                    Image(systemName: "house")
                    Text("메인")
                }
            
            MemoryLeakTestView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle")
                    Text("메모리테스트")
                }
        }
    }
}

struct MemoryLeakTestView: View {
    @State private var leaks: [Data] = []
    @State private var isLeaking = false

    var body: some View {
        VStack(spacing: 20) {
            Button(isLeaking ? "Stop Leaking" : "Start Memory Leak") {
                isLeaking.toggle()
                if isLeaking {
                    startLeaking()
                }
            }
            .padding()
            .background(isLeaking ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            Text("Leak count: \(leaks.count)")
        }
        .padding()
    }

    func startLeaking() {
        DispatchQueue.global().async {
            while isLeaking {
                let leak = Data(count: 2_000_000) // 2MB
                DispatchQueue.main.async {
                    leaks.append(leak)
                }
                usleep(1_000_000) // 1초 대기
            }
        }
    }
}

#Preview {
    ContentView()
}
