//
//  InventoryParts.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 7/9/25.
//

import Foundation

struct InventoryParts: Codable {
    
    // Rebrickable paginates list endpoints. `count` is the total number of
    // parts in the set, while `next`/`previous` are fully-formed URLs (key and
    // page params already included) used to walk through the remaining pages.
    let count: Int?
    let next: String?
    let previous: String?
    let results: [PartResult]
    
    enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
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
