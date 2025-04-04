import Foundation
import SwiftUI
import AsleepSDK

class SettingsViewModel: ObservableObject {
    @AppStorage("com.sleepmood.userId") var userId: String = "-"
    let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    
    init() {
        userId = UserDefaults.standard.string(forKey: "sleepmood+userId") ?? "-"
    }
} 
