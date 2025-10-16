//
//  LegoSetsDataModel.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 10/16/25.
//

import Foundation
import SwiftData

@Model
class LegoSetsDataModel {
    var setNumber: String?
    var name: String?
    var year: Int?
    var themeID: Int?
    var numberOfParts: Int?
    var setImageURL: String?
    var setURL: String?
    var lastModifieDT: String?
    
    init(setNumber: String? = nil, name: String? = nil, year: Int? = nil, themeID: Int? = nil, numberOfParts: Int? = nil, setImageURL: String? = nil, setURL: String? = nil, lastModifieDT: String? = nil) {
        self.setNumber = setNumber
        self.name = name
        self.year = year
        self.themeID = themeID
        self.numberOfParts = numberOfParts
        self.setImageURL = setImageURL
        self.setURL = setURL
        self.lastModifieDT = lastModifieDT
    }
}
