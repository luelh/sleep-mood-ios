import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var asleepManager: AsleepManager
    @State private var showingColorPicker = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("User Information")) {
                    HStack {
                        Text("User ID")
                        Spacer()
                        Text(asleepManager.userId)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Light Settings")) {
                    Button(action: {
                        showingColorPicker = true
                    }) {
                        HStack {
                            Text("Light Color")
                            Spacer()
                            Circle()
                                .fill(asleepManager.lightColor)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(selectedColor: $asleepManager.lightColor)
            }
        }
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ColorPicker("Select Color", selection: $selectedColor)
                .padding()
                .navigationTitle("Choose Color")
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
} 