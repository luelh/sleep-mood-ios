import Foundation
import AsleepSDK

class SleepAnalysisViewModel: ObservableObject {
    private let configService = ConfigService.shared
    private var reports: Asleep.Reports?
    private var fromDate: String = "2025-01-01"
    private var toDate: String = "2025-04-04"
    private var isCreatingReportList = false
    private var hasInitialConfig = false
    
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
//        
//        // 초기 config 상태 확인
//        hasInitialConfig = configService.config != nil
    }
    
    @objc private func configDidUpdate() {
        createReportList()
    }
    
//    func checkConfigAndCreateReportList() {
//        guard !isCreatingReportList else { 
//            print("Report list creation already in progress")
//            return 
//        }
//        
//        if configService.config != nil {
//            if !hasInitialConfig {
//                hasInitialConfig = true
//                createReportList()
//            }
//        } else {
//            print("Initializing Asleep config")
//            configService.initAsleepConfig()
//        }
//    }
    
    func createReportList() {
//        guard !isCreatingReportList else { 
//            print("Skipping createReportList - already in progress")
//            return 
//        }
//        
//        isCreatingReportList = true
//        print("Creating report list - Config exists:", configService.config != nil)
        
        reports = configService.createReports()
        if reports != nil {
            fetchReportList()
        } else {
            print("No config available for creating reports")
            isCreatingReportList = false
        }
    }
    
    private func fetchReportList() {
        Task {
            do {
                let reportList = try await reports?.reports(fromDate: fromDate, toDate: toDate)
                await MainActor.run {
                    self.reportList = reportList ?? []
                    print("Fetched report list count:", self.reportList.count)
                    self.isCreatingReportList = false
                }
            } catch {
                print("Failed to fetch report list:", error)
                self.isCreatingReportList = false
            }
        }
    }
    
    private func fetchReport() {
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
