import SwiftUI

struct MoodLightView: View {
    @EnvironmentObject var asleepManager: AsleepManager
    @State private var isLightOn = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLightOn.toggle()
                    }
                }) {
                    ZStack {
                        if isLightOn {
                            Circle()
                                .fill(asleepManager.lightColor)
                                .frame(width: 350, height: 350)
                                .blur(radius: 20)
                                .opacity(0.5)
                        }
                        
                        Circle()
                            .fill(isLightOn ? asleepManager.lightColor : .gray)
                            .frame(width: 300, height: 300)
                            .shadow(color: isLightOn ? asleepManager.lightColor : .clear,
                                   radius: 20, x: 0, y: 0)
                    }
                }
                
                Spacer()
            }
        }
    }
} 
