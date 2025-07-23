//
//  ControlImageView.swift
//  Pinch
//
//  Created by Ankush Ganesh on 22/07/25.
//

import SwiftUI

struct ControlImageView: View {
    let icon: String
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 30))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ControlImageView(icon: "minus.magnifyingglass")
        .preferredColorScheme(.dark)
}
