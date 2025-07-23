//
//  PageModel.swift
//  Pinch
//
//  Created by Ankush Ganesh on 23/07/25.
//

import Foundation

struct Page: Identifiable {
    let id: Int
    let imageName: String
}

extension Page {
    var thumbnailName: String {
        return "thumb-" + imageName
    }
}
