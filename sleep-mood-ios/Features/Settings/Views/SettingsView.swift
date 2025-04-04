import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingColorPicker = false
    @State private var selectedLightColor = RGBAColor(red: 1, green: 1, blue: 0, alpha: 0.5)
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("사용자 정보")) {
                    HStack {
                        Text("사용자 ID")
                        Spacer()
                        Text(viewModel.userId)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("버전")
                        Spacer()
                        Text(viewModel.version)
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("조명 설정")) {
                    Button(action: {
                        showingColorPicker = true
                    }) {
                        HStack {
                            Text("조명 색상")
                            Spacer()
                            Circle()
                                .fill(selectedLightColor.color)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
            .navigationTitle("설정")
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(selectedColor: Binding(
                    get: { selectedLightColor.color },
                    set: { newColor in
                        selectedLightColor = RGBAColor(color: newColor)
                        viewModel.saveLightColor(selectedLightColor)
                    }
                ))
            }
            .onAppear {
                viewModel.refreshUserId()
                selectedLightColor = viewModel.loadLightColor()
            }
        }
    }
}
