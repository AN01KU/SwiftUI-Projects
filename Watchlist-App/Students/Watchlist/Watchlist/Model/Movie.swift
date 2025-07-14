//
//  Item.swift
//  Watchlist
//
//  Created by Ankush Ganesh on 03/07/25.
//

import Foundation
import SwiftData

@Model
final class Movie {
    var title: String
    var genre: Genre
    
    init (title: String, genre: Genre) {
        self.title = title
        self.genre = genre
    }
}

extension Movie {
    @MainActor
    static var preview: ModelContainer {
        let containter = try! ModelContainer(for: Movie.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        containter.mainContext.insert(Movie(title: "Toy Story", genre: .kids))
        containter.mainContext.insert(Movie(title: "Titanic", genre: .romance))
        containter.mainContext.insert(Movie(title: "Oppenheimer", genre: .scifi))
        containter.mainContext.insert(Movie(title: "Phir Hera Pheri", genre: .comedy))
        containter.mainContext.insert(Movie(title: "La La Land", genre: .musical))
        containter.mainContext.insert(Movie(title: "A Quite Place", genre: .thriller))
        containter.mainContext.insert(Movie(title: "Harry Potter", genre: .fantasy))
        
        return containter
    }
}
