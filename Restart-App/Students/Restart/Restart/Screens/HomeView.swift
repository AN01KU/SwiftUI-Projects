//
//  HomeView.swift
//  Restart
//
//  Created by Ankush Ganesh on 05/07/25.
//

import SwiftUI

struct HomeView: View {
    // MARK: - PROPERTIES
    
    @AppStorage("onboarding") var isOnboardingViewActive: Bool = false
    @State private var isAnimating: Bool = false
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 20) {
            // MARK: HEADER
            Spacer()
            
            ZStack {
                CircleGroupView(ShapeColor: .gray, ShapeOpacity: 0.1)
                
                Image("character-2")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .offset(y: isAnimating ? 35: -35)
                    .animation(
                        Animation
                            .easeInOut(duration: 4)
                            .repeatForever(),
                        value: isAnimating
                    )
            }
            .padding(12)
            
            // MARK: CENTER
            Text("The time that leds to mastery us dependent on the intensity of our focus.")
                .font(.title3.weight(.light))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            // MARK: FOOTER
            Spacer()
            
            Button {
                withAnimation {
                    isOnboardingViewActive = true
                    playSound(sound: "success", type: "m4a")
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .imageScale(.large)
                Text("Restart")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
            } //: Button
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .padding()
//            .opacity(isAnimating ? 1 : 0)
//            .offset(y: isAnimating ? 0: 20)
//            .animation(.easeOut(duration: 0.5), value: isAnimating)
        } //: VStack
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    HomeView()
}
