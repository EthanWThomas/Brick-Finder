//
//  LegoMOCs.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 7/9/25.
//

import Foundation

struct LegoMOCS: Codable {
    let results: [LegoMOCSResult]
    
    struct LegoMOCSResult: Codable {
        let setNumber: String?
        let name: String?
        let year: Int?
        let themeId: Int?
        let numberOfPart: Int?
        let mocImageUrl: String?
        let mocURl: String?
        let designerName: String?
        let designerUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case setNumber = "set_num"
            case name
            case year
            case themeId = "theme_id"
            case numberOfPart = "num_parts"
            case mocImageUrl = "moc_img_url"
            case mocURl = "moc_url"
            case designerName = "designer_name"
            case designerUrl = "designer_url"
        }
    }
}
