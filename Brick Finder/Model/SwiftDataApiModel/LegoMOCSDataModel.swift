//
//  LegoMOCSDataModel.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 10/16/25.
//

import Foundation
import SwiftData

@Model
class LegoMOCSDataModel {
    var setNumber: String?
    var name: String?
    var year: Int?
    var themeId: Int?
    var numberOfPart: Int?
    var mocImageUrl: String?
    var mocURl: String?
    var designerName: String?
    var designerUrl: String?
    
    init(setNumber: String? = nil, name: String? = nil, year: Int? = nil, themeId: Int? = nil, numberOfPart: Int? = nil, mocImageUrl: String? = nil, mocURl: String? = nil, designerName: String? = nil, designerUrl: String? = nil) {
        self.setNumber = setNumber
        self.name = name
        self.year = year
        self.themeId = themeId
        self.numberOfPart = numberOfPart
        self.mocImageUrl = mocImageUrl
        self.mocURl = mocURl
        self.designerName = designerName
        self.designerUrl = designerUrl
    }
}
