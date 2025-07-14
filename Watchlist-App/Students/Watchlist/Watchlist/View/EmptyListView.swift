//
//  EmptyListView.swift
//  Watchlist
//
//  Created by Ankush Ganesh on 05/07/25.
//

import SwiftUI

struct EmptyListView: View {
    var body: some View {
        ContentUnavailableView {
            Circle()
                .fill(.blue.gradient)
                .stroke(.blue.gradient.opacity(0.15), lineWidth: 30)
                .stroke(.blue.gradient.opacity(0.15), lineWidth: 60)
                .stroke(.blue.gradient.opacity(0.15), lineWidth: 90)
                .frame(width: 180)
                .overlay {
                    Image(systemName: "movieclapper")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .foregroundStyle(Color(UIColor.secondarySystemBackground))
                        .padding(.top, -6)
                }
                .padding(.bottom, 90)
        } description: {
            GroupBox {
                TabView {
                    PageTabView(icon: "1.circle", description: "Add some movies to the watchlist if you plan to watch later")
                        .padding(.bottom, 36)
                    PageTabView(icon: "2.circle", description: "Later on you can also choose a random film to watch")
                        .padding(.bottom, 36)
                }
                .tabViewStyle(.page)
                .frame(minWidth: 0, maxWidth: 650, minHeight: 120, maxHeight: 180)
            }
        }
    }
}

#Preview("Light Theme") {
    EmptyListView()
}

#Preview("Dark Theme") {
    EmptyListView()
        .preferredColorScheme(.dark)
}
