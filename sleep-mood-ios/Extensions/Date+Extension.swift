import Foundation

extension Date {
    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var fullDateString: String {
        return Date.fullDateFormatter.string(from: self)
    }
} 