//
//  LegoColor.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/5/25.
//

import Foundation

struct LegoColor: Codable {
    
    let results: [PartsAndColorResults]
    
    struct PartsAndColorResults: Codable {
        let colorID: Int
        let colorName: String
        let numberOfSet: Int
        let numberOfSetParts: Int
        let partImageUrL: String
//        let elements: [String]
        
        enum CodingKeys: String, CodingKey {
            case colorID = "color_id"
            case colorName = "color_name"
            case numberOfSet = "num_sets"
            case numberOfSetParts = "num_set_parts"
            case partImageUrL = "part_img_url"
//            case elements = "elements"
        }
    }
}

struct ColorCombination: Codable {
    let partImageUrL: String?
    let yearFrom: Int
    let yearTo: Int
    let numberSet: Int
    let numberOfSetParts: Int
    
    enum CodingKeys: String, CodingKey {
        case partImageUrL = "part_img_url"
        case yearFrom = "year_from"
        case yearTo = "year_to"
        case numberSet = "num_sets"
        case numberOfSetParts = "num_set_parts"
    }
}
