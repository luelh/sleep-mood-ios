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
        }
    }
}

#Preview {
    ContentView()
}
