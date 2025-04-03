import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MoodLightView()
                .tabItem {
                    Label("무드등", systemImage: "lightbulb.fill")
                }
            
            SleepAnalysisView()
                .tabItem {
                    Label("수면분석", systemImage: "bed.double.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gear")
                }
        }
    }
} 