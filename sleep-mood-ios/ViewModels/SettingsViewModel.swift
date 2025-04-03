import Foundation
import SwiftUI
import AsleepSDK

class SettingsViewModel: ObservableObject {
    @AppStorage("com.sleepmood.userId") var userId: String = "-"
    let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    
    init() {
        // UserDefaults에서 userId 가져오기
        userId = UserDefaults.standard.string(forKey: "com.sleepmood.userId") ?? "-"
    }
} 
