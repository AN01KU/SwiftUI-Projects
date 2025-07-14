//
//  PawsApp.swift
//  Paws
//
//  Created by Ankush Ganesh on 10/06/25.
//

import SwiftUI
import SwiftData

@main
struct PawsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Pet.self)
        }
    }
}
