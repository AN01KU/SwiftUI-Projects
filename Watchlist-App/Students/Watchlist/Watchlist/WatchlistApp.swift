//
//  WatchlistApp.swift
//  Watchlist
//
//  Created by Ankush Ganesh on 03/07/25.
//

import SwiftUI
import SwiftData

@main
struct WatchlistApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Movie.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
