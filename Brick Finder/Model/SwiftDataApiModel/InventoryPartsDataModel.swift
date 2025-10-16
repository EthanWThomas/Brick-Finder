//
//  InventoryPartsDataModel.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 10/16/25.
//

import Foundation
import SwiftData

@Model
class InventoryPartsDataModel {
    var id: Int?
    var inventoryPartId: Int?
    var part: InventoryParts.Part
    var setNumber: String?
    var quantity: Int
    var isSpare: Bool
    var elementId: String?
    var numberOfSet: Int
    
    init(id: Int? = nil, inventoryPartId: Int? = nil, part: InventoryParts.Part, setNumber: String? = nil, quantity: Int, isSpare: Bool, elementId: String? = nil, numberOfSet: Int) {
        self.id = id
        self.inventoryPartId = inventoryPartId
        self.part = part
        self.setNumber = setNumber
        self.quantity = quantity
        self.isSpare = isSpare
        self.elementId = elementId
        self.numberOfSet = numberOfSet
    }
}
