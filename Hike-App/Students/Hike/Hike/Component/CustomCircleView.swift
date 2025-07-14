//
//  CustomCircleView.swift
//  Hike
//
//  Created by Ankush Ganesh on 08/06/25.
//

import SwiftUI

struct CustomCircleView: View {
    @State private var isAnimateGradient: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            .colorIndigoMedium,
                            .customSalmonLight
                        ],
                        startPoint: isAnimateGradient ? .topLeading : .bottom,
                        endPoint: isAnimateGradient ? .bottomTrailing : .topTrailing)
                )
                .onAppear {
                    withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                        isAnimateGradient.toggle()
                    }
                }
            MotionAnimationView()
            
        } //: ZStack
        .frame(width: 256, height: 256)
    }
}

#Preview {
    CustomCircleView()
}
