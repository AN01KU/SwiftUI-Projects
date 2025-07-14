//
//  WishlistApp.swift
//  Wishlist
//
//  Created by Ankush Ganesh on 08/06/25.
//

import SwiftUI
import SwiftData

@main
struct WishlistApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Wish.self)
        }
    }
}
