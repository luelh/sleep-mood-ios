import Foundation
import AsleepSDK

class SleepAnalysisViewModel: ObservableObject {
    @Published var reportList: [Asleep.Model.SleepSession] = []
    @Published var selectedSessionId: String?
    @Published var selectedReport: Asleep.Model.Report?
    @Published var isAnalyzing = false
    var reports: Asleep.Reports? = nil
    
    func fetchReport() {
        guard let sessionId = selectedSessionId else { return }
        
        Task {
            if let fetchedReport = try? await reports?.report(sessionId: sessionId) {
                selectedReport = fetchedReport
            }
        }
    }
}
