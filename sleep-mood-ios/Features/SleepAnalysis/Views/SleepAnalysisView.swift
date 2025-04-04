import SwiftUI
import AsleepSDK

struct SleepAnalysisView: View {
    @EnvironmentObject private var viewModel: SleepAnalysisViewModel

    var body: some View {
        VStack {
            if viewModel.reportList.isEmpty {
                emptyView
            } else {
                reportListView
            }
        }
        .navigationTitle("수면 분석")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.createReportList()
        }
    }

    var emptyView: some View {
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
    }

    var reportListView: some View {
        List {
            ForEach(viewModel.reportList, id: \.sessionId) { item in
                NavigationLink(
                    destination: SleepAnalysisDetailView(report: viewModel.selectedReport),
                    tag: item.sessionId,
                    selection: $viewModel.selectedSessionId
                ) {
                    VStack(alignment: .leading) {
                        Text("ID: \(item.sessionId)")
                        Text("State: \(item.state)")
                        Text("Start time: \(item.sessionStartTime)")
                        if let endTime = item.sessionEndTime {
                            Text("End time: \(endTime)")
                        }
                    }
                }
            }
        }
    }
}
