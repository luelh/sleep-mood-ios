import SwiftUI
import AsleepSDK

struct SleepAnalysisView: View {
    @EnvironmentObject var asleepManager: AsleepManager
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationView {
            VStack {
                if asleepManager.sessions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bed.double")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("아직 수면 데이터가 없습니다")
                            .font(.headline)
                        Text("수면 분석을 시작하여 데이터를 수집하세요")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List(asleepManager.sessions) { session in
                        NavigationLink(destination: SleepAnalysisDetailView(session: session)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(session.date, style: .date)")
                                    .font(.headline)
                                HStack {
                                    Label(session.formattedDuration, systemImage: "clock")
                                    Spacer()
                                    Label(session.qualityPercentage, systemImage: "chart.bar.fill")
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if isAnalyzing {
                        asleepManager.stopSleepAnalysis()
                    } else {
                        asleepManager.startSleepAnalysis()
                    }
                    isAnalyzing.toggle()
                }) {
                    HStack {
                        Image(systemName: isAnalyzing ? "stop.circle.fill" : "play.circle.fill")
                        Text(isAnalyzing ? "수면 분석 중지" : "수면 분석 시작")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAnalyzing ? Color.red : Color.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("수면 분석")
        }
    }
}

struct SleepSession: Identifiable {
    let id: String
    let date: Date
    // Add other session properties as needed
}

struct SleepAnalysisDetailView: View {
    let session: SleepSession
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 수면 시간 정보
                VStack(alignment: .leading, spacing: 10) {
                    Text("수면 시간")
                        .font(.headline)
                    HStack {
                        Image(systemName: "clock")
                        Text(session.formattedDuration)
                    }
                    .font(.title2)
                }
                
                // 수면 품질 정보
                VStack(alignment: .leading, spacing: 10) {
                    Text("수면 품질")
                        .font(.headline)
                    HStack {
                        Image(systemName: "chart.bar.fill")
                        Text(session.qualityPercentage)
                    }
                    .font(.title2)
                }
                
                // 추가 분석 정보가 있다면 여기에 추가
            }
            .padding()
        }
        .navigationTitle("수면 분석 리포트")
    }
} 