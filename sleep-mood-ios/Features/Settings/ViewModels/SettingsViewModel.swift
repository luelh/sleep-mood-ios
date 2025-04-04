import Foundation
import AsleepSDK

final class SettingsViewModel: ObservableObject {
    
    
    // MARK: - private properties
    
    private(set) var version: String
    private let colorKey = "sleepmood+lightColor"
    
    
    // MARK: - published state
    
    @Published var userId: String = "-"
    
    
    // MARK: - initialize

    init() {
        self.version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    
    // MARK: - internal method

    func refreshUserId() {
        userId = UserDefaults.standard.string(forKey: "sleepmood+userId") ?? "-"
    }
    
    func loadLightColor() -> RGBAColor {
        if let data = UserDefaults.standard.data(forKey: colorKey),
           let decoded = try? JSONDecoder().decode(RGBAColor.self, from: data) {
            return decoded
        }

        // 기본 색상 (노란색, 50% 투명도)
        return RGBAColor(red: 1, green: 1, blue: 0, alpha: 0.5)
    }

    func saveLightColor(_ rgba: RGBAColor) {
        if let data = try? JSONEncoder().encode(rgba) {
            UserDefaults.standard.set(data, forKey: colorKey)
        }
    }
}
