//
//  CustomContentUnavailableView.swift
//  Paws
//
//  Created by Ankush Ganesh on 10/06/25.
//

import SwiftUI

struct CustomContentUnavailableView: View {
    
    var icon: String
    var title: String
    var description: String
    
    var body: some View {
        ContentUnavailableView {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 96)
            
            Text(title)
                .font(.title)
            
        } description: {
            Text(description)
        }
        .foregroundStyle(.tertiary)
    }
}

#Preview {
    CustomContentUnavailableView(icon: "cat.circle", title: "No Photo", description: "Add a photo to get started")
}
