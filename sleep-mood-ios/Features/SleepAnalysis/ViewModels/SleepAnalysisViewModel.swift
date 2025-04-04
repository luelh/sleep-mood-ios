import Foundation
import AsleepSDK

class SleepAnalysisViewModel: ObservableObject {
    private let configService = ConfigService.shared
    private var reports: Asleep.Reports?
    private var fromDate: String = "2025-01-01"
    private var toDate: String = "2025-04-04"
    
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
    
    init() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(configDidUpdate),
            name: .asleepConfigDidUpdate,
            object: nil
        )
        
        // 초기 config가 있다면 바로 리포트 생성
        if configService.config != nil {
            createReportList()
        } else {
            configService.initAsleepConfig()
        }
    }
    
    @objc private func configDidUpdate() {
        print("Config updated - Creating report list")
        createReportList()
    }
    
    func createReportList() {
        print("Creating report list - Config exists:", configService.config != nil)
        reports = configService.createReports()
        if reports != nil {
            fetchReportList()
        } else {
            print("No config available for creating reports")
        }
    }
    
    func fetchReportList() {
        Task {
            do {
                let reportList = try await reports?.reports(fromDate: fromDate, toDate: toDate)
                await MainActor.run {
                    self.reportList = reportList ?? []
                    print("Fetched report list count:", self.reportList.count)
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
