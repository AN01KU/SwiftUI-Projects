//
//  WishModel.swift
//  Wishlist
//
//  Created by Ankush Ganesh on 08/06/25.
//

import Foundation
import SwiftData

@Model
class Wish {
    var title: String
    
    init(title: String) {
        self.title = title
    }
}
