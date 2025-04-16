import Foundation
import AsleepSDK

class SleepAnalysisViewModel: ObservableObject {
    
    
    // MARK: - dependencies
    
    private let configService = ConfigService.shared
    
    
    // MARK: - private properties
    
    private var reports: Asleep.Reports?
    private var fromDate: String = "2025-01-01"
    private var toDate: String = Date().simpleDateString
    
    
    // MARK: - published state
    
    @Published var reportList: [Asleep.Model.SleepSession] = []
    @Published var selectedSessionId: String? = nil {
        didSet {
            if selectedSessionId != nil {
                fetchReport()
            }
        }
    }
    @Published var selectedReport: Asleep.Model.Report? = nil
    @Published var isAnalyzing = false
    
    
    // MARK: - Initialize
    
    init() {
//        NotificationCenter.default.addObserver(self, selector: #selector(configDidUpdate), name: .asleepConfigDidUpdate, object: nil)
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    @objc private func configDidUpdate() {
//        createReportList()
//    }
    
    
    // MARK: - private method
    
    private func fetchReportList() {
        guard let reports else { return }

        Task {
            do {
                let list = try await reports.reports(fromDate: fromDate, toDate: toDate)
                await MainActor.run {
                    self.reportList = list
                    print("Fetched report list: \(self.reportList.count) items")
                }
            } catch {
                await MainActor.run {
                    print("Failed to fetch report list:", error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchReport() {
        guard let sessionId = selectedSessionId else { return }
        
        Task {
            do {
                let report = try await reports?.report(sessionId: sessionId)
                await MainActor.run {
                    self.selectedReport = report
                    print("Fetched report for sessionId:", sessionId)
                }
            } catch {
                await MainActor.run {
                    print("Failed to fetch report for sessionId \(sessionId):", error.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK: - internal method
    
    func createReportList() {
        guard let _ = configService.config else { return }
        guard let reports = configService.createReports() else {
            print("No config available for creating reports")
            return
        }
        self.reports = reports
        fetchReportList()
    }
}
