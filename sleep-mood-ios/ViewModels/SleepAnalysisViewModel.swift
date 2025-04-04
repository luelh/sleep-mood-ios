import Foundation
import AsleepSDK

class SleepAnalysisViewModel: ObservableObject {
//    private var config: Asleep.Config? {
//        if let configData = UserDefaults.standard.data(forKey: "sleepmood+config") {
//            do {
//                return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(configData) as? Asleep.Config
//            } catch {
//                print("Failed to unarchive config:", error)
//                return nil
//            }
//        }
//        return nil
//    }
    
    private var reports: Asleep.Reports?
    private var fromDate: String = "2025-01-01"
    private var toDate: String = "2025-04-04"
    
    @Published var reportList: [Asleep.Model.SleepSession] = []
    @Published var selectedSessionId: String? = nil
    @Published var selectedReport: Asleep.Model.Report? = nil
    @Published var isAnalyzing = false
    
    func fetchReportList() {
        Task {
            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            if let reportList = try? await reports?.reports(fromDate: yesterday.simpleDateString,
                                                            toDate: today.simpleDateString) {
                self.reportList = reportList
            }
        }
        Task {
            do {
                let reportList = try await reports?.reports(fromDate: fromDate, toDate: toDate)
                await MainActor.run {
                    self.reportList = reportList ?? []
                }
            } catch {
                print("Failed to fetch report list:", error)
            }
        }
    }
    
    func fetchReport() {
        guard let sessionId = selectedSessionId else { return }
        
        Task {
            if let fetchedReport = try? await reports?.report(sessionId: sessionId) {
                await MainActor.run {
                    selectedReport = fetchedReport
                }
            }
        }
    }
}

extension SleepAnalysisViewModel {
    
}
