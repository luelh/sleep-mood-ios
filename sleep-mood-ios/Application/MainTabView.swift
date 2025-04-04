import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                MoodLightView()
            }
            .tabItem {
                Label("무드등", systemImage: "lightbulb.fill")
            }

            NavigationView {
                SleepAnalysisView()
            }
            .tabItem {
                Label("수면분석", systemImage: "bed.double.fill")
            }

            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("설정", systemImage: "gear")
            }
        }
    }
}
