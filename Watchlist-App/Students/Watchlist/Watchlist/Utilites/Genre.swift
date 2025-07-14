//
//  Genre.swift
//  Watchlist
//
//  Created by Ankush Ganesh on 03/07/25.
//

import Foundation

enum Genre: Int, Codable, CaseIterable, Identifiable {
    var id: Int { rawValue }
    
    case action = 1
    case comedy
    case crime
    case documentary
    case drama
    case fantasy
    case kids
    case musical
    case scifi
    case romance
    case thriller
    case western
}

extension Genre {
    var name: String {
        switch self {
        case .action:
            return "Action"
        case .comedy:
            return "Comedy"
        case .crime:
            return "Crime"
        case .documentary:
            return "Documentary"
        case .drama:
            return "Drama"
        case .fantasy:
            return "Fantasy"
        case .kids:
            return "Kids"
        case .musical:
            return "Musical"
        case .scifi:
            return "Sci-Fi"
        case .romance:
            return "Romance"
        case .thriller:
            return "Thriller"
        case .western:
            return "Western"
        }
    }
}
