//
//  InventoryParts.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 7/9/25.
//

import Foundation

struct InventoryParts: Codable {
    
    let results: [PartResult]
    
    enum CodingKeys: String, CodingKey {
        case results = "results"
    }
    
    struct PartResult: Codable {
        let id: Int?
        let inventoryPartId: Int?
        let part: InventoryParts.Part
        let setNumber: String
        let quantity: Int
        let isSpare: Bool
        let elementId: String?
        let numberOfSet: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case inventoryPartId = "inv_part_id"
            case part
            case setNumber = "set_num"
            case quantity = "quantity"
            case isSpare = "is_spare"
            case elementId = "element_id"
            case numberOfSet = "num_sets"
        }
    }
}
