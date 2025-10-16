//
//  LegoPartsDataModel.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 10/16/25.
//

import Foundation
import SwiftData

@Model
class LegoPartsDataModel {
    var partNumber: String?
    var name: String?
    var partCatId: Int?
    var partUrl: String?
    var partImageUrl: String?
    
    init(partNumber: String? = nil, name: String? = nil, partCatId: Int? = nil, partUrl: String? = nil, partImageUrl: String? = nil) {
        self.partNumber = partNumber
        self.name = name
        self.partCatId = partCatId
        self.partUrl = partUrl
        self.partImageUrl = partImageUrl
    }
}
