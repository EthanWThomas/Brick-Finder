//
//  LegoColorDataModel.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 10/16/25.
//

import Foundation
import SwiftData

@Model
class LegoColorDataModel {
    var colorID: Int
    var colorName: String
    var numberOfSet: Int
    var numberOfSetParts: Int
    var partImageUrL: String
    
    init(colorID: Int, colorName: String, numberOfSet: Int, numberOfSetParts: Int, partImageUrL: String) {
        self.colorID = colorID
        self.colorName = colorName
        self.numberOfSet = numberOfSet
        self.numberOfSetParts = numberOfSetParts
        self.partImageUrL = partImageUrL
    }
}

@Model
class ColorCombinationDataModel {
    var partImageUrL: String?
    var yearFrom: Int
    var yearTo: Int
    var numberSet: Int
    var numberOfSetParts: Int
    
    init(partImageUrL: String? = nil, yearFrom: Int, yearTo: Int, numberSet: Int, numberOfSetParts: Int) {
        self.partImageUrL = partImageUrL
        self.yearFrom = yearFrom
        self.yearTo = yearTo
        self.numberSet = numberSet
        self.numberOfSetParts = numberOfSetParts
    }
}
