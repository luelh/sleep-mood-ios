import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingColorPicker = false
    
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
                                .fill(Color.yellow.opacity(0.5))
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
            .navigationTitle("설정")
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(selectedColor: .constant(Color.yellow.opacity(0.5)))
            }
        }
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ColorPicker("색상 선택", selection: $selectedColor)
                .padding()
                .navigationTitle("색상 선택")
                .navigationBarItems(trailing: Button("완료") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
} 
