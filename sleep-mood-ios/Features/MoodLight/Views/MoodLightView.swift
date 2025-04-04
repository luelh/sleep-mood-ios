import SwiftUI

struct MoodLightView: View {
    @EnvironmentObject private var viewModel: MoodLightViewModel
    
    var body: some View {
        let lightColor = viewModel.lightColor.color
        
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Button(action: {
                    viewModel.toggleLight()
                }) {
                    ZStack {
                        if viewModel.isLightOn {
                            Circle()
                                .fill(lightColor)
                                .frame(width: 350, height: 350)
                                .blur(radius: 20)
                                .opacity(0.5)
                        }
                        
                        Circle()
                            .fill(viewModel.isLightOn ? lightColor : .gray)
                            .frame(width: 300, height: 300)
                            .shadow(color: viewModel.isLightOn ? lightColor : .clear,
                                   radius: 20, x: 0, y: 0)
                    }
                }
                
                Spacer()
                
                Text(viewModel.isTracking ? "Record 중..." : "Record 대기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .navigationTitle("무드등")
        .navigationBarTitleDisplayMode(.inline)
    }
} 
