//
//  LegoDataModel.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 10/15/25.
//

import Foundation
import SwiftData

@Model
class LegoDataModel {
    var setNum: String?
    var name: String?
    var numberOfParts: Int?
    var setImageUrl: String?
    var setUrl: String?
    var lastModifledDT: String?
    
    init(setNum: String? = nil, name: String? = nil, numberOfParts: Int? = nil, setImageUrl: String? = nil, setUrl: String? = nil, lastModifledDT: String? = nil) {
        self.setNum = setNum
        self.name = name
        self.numberOfParts = numberOfParts
        self.setImageUrl = setImageUrl
        self.setUrl = setUrl
        self.lastModifledDT = lastModifledDT
    }
}
