import Foundation
import AsleepSDK

class SleepAnalysisViewModel: ObservableObject {
    @Published var reportList: [Asleep.Model.SleepSession] = []
    @Published var selectedSessionId: String?
    @Published var selectedReport: Asleep.Model.Report?
    @Published var isAnalyzing = false
} 
