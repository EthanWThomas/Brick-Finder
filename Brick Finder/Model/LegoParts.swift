//
//  LegoParts.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 7/9/25.
//

import Foundation

struct AllParts: Codable {
    let results: [PartResults]
    
    struct PartResults: Codable {
        let partNumber: String?
        let name: String?
        let partCatId: Int?
        let partUrl: String?
        let partImageUrl: String?
//        let externalIds: ExternalIds?
        
        enum CodingKeys: String, CodingKey {
            case partNumber = "part_num"
            case name = "name"
            case partCatId = "part_cat_id"
            case partImageUrl = "part_img_url"
//            case externalIds = "external_ids"
            case partUrl = "part_url"
        }
        
        struct ExternalIds: Codable {
            let brickLink: [String]
            let brickOwl: [String]
            
            enum CodingKeys: String, CodingKey {
                case brickLink = "BrickLink"
                case brickOwl = "BrickOwl"
            }
        }
    }
}

struct LegoParts: Codable {
    let partNum: String
    let name: String
    let partCatId: Int?
    let yaerFrom: Int?
    let yearTo: Int?
    let partImageUrl: String?
    let partUrl: String?
    let molds: [String?]
    
    enum CodingKeys: String, CodingKey {
        case partNum = "part_num"
        case name
        case partCatId = "part_cat_id"
        case yaerFrom = "year_from"
        case yearTo = "year_to"
        case partImageUrl = "part_img_url"
        case partUrl = "part_url"
        case molds
    }
}
