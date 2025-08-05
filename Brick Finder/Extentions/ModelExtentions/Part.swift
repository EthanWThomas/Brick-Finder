//
//  Parts.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 7/9/25.
//

import Foundation

extension InventoryParts {
    
    struct Part: Codable {
        let partNumber: String?
        let name: String?
        let partID: Int?
        let partURL: String?
        let partImageURL: String?
//        let externalID: ExternalIDs?
//        let color: ColorOFPart?
        
        enum CodingKeys: String, CodingKey {
            case partNumber = "part_num"
            case name
            case partID = "part_cat_id"
            case partURL = "part_url"
            case partImageURL = "part_img_url"
//            case externalID = "external_ids"
//            case color
        }
        
        struct ExternalIDs: Codable {
            let brickLing: [String]?
            let brickOwl: [String]?
            let ldraw: [String]?
            let lego: [String]?
            
            enum CodingKeys: String, CodingKey {
                case brickLing = "BrickOwl"
                case brickOwl = "Brickset"
                case ldraw = "LDraw"
                case lego = "LEGO"
            }
        }
        
        struct ColorOFPart: Codable {
            let id: Int?
            let name: String?
            let rgb: String?
            let isTrans: Bool?
//            let externalIds: ColorExternalIDs?
            
            enum CodingKeys: String, CodingKey {
                case id
                case name
                case rgb
                case isTrans = "is_trans"
//                case externalIds = "external_ids"
            }
        }
    }
}
