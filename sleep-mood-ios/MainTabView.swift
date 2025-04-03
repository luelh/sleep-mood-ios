import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MoodLightView()
                .tabItem {
                    Label("Mood Light", systemImage: "lightbulb.fill")
                }
            
            SleepAnalysisView()
                .tabItem {
                    Label("Sleep Analysis", systemImage: "bed.double.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
} 