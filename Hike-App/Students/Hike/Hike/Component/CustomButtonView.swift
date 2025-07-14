//
//  CustomButtonView.swift
//  Hike
//
//  Created by Ankush Ganesh on 08/06/25.
//

import SwiftUI

struct CustomButtonView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white,
                            .customGreenLight,
                            .customGreenMedium],
                        startPoint: .top,
                        endPoint: .bottom)
                )
            
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                        .customGrayMedium,
                        .customGrayMedium ],
                        startPoint: .top,
                        endPoint: .bottom),
                    lineWidth: 4)
                
            Image(systemName: "figure.hiking")
                .fontWeight(.black)
                .font(.system(size: 30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .customGrayMedium,
                            .customGrayMedium
                        ],
                        startPoint: .top,
                        endPoint: .bottom)
                )
        } //: ZSTACK
        .frame(width: 58, height: 58)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    CustomButtonView()
        .padding()
}
