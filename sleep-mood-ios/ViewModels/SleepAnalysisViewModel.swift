import Foundation
import AsleepSDK

class SleepAnalysisViewModel: ObservableObject {
    @Published var sessions: [SleepSession] = []
    @Published var isAnalyzing = false
//    
    private var asleepSDK: Asleep?
//
//    init() {
//        do {
//            asleepSDK = try AsleepSDK()
//            loadSessions()
//        } catch {
//            print("AsleepSDK 초기화 실패: \(error)")
//        }
//    }
//    
//    func loadSessions() {
//        guard let sdk = asleepSDK else { return }
//        
//        do {
//            let sleepData = try sdk.getSleepData()
//            sessions = sleepData.map { data in
//                SleepSession(
//                    id: data.sessionId,
//                    date: data.startTime,
//                    duration: data.duration,
//                    quality: data.quality
//                )
//            }
//        } catch {
//            print("수면 데이터 로드 실패: \(error)")
//        }
//    }
//    
    func toggleAnalysis() {
//        guard let sdk = asleepSDK else { return }
//        
//        do {
//            if isAnalyzing {
//                try sdk.stopAnalysis()
//                loadSessions()
//            } else {
//                try sdk.startAnalysis()
//            }
//            isAnalyzing.toggle()
//        } catch {
//            print("수면 분석 \(isAnalyzing ? "중지" : "시작") 실패: \(error)")
//        }
    }
} 
