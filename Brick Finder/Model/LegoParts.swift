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
