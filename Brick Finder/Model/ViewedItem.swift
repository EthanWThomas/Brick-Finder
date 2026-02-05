//
//  ViewedItem.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 1/13/26.
//

import Foundation
import SwiftData

@Model
class ViewedItem {
    var setNum: String?
    var name: String?
    var type: String
    var imageURL: String?
    var timestamp: Date
    
    init(setNum: String? = nil, name: String? = nil, type: String, imageURL: String? = nil) {
        self.setNum = setNum
        self.name = name
        self.type = type
        self.imageURL = imageURL
        self.timestamp = Date.now
    }
}
