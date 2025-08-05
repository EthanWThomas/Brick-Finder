//
//  LegoSet.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 7/9/25.
//

import Foundation

struct LegoSet: Codable {
    let results: [SetResults]
    
    struct SetResults: Codable {
        let setNumber: String?
        let name: String?
        let year: Int?
        let themeID: Int?
        let numberOfParts: Int?
        let setImageURL: String?
        let setURL: String?
        let lastModifieDT: String?
        
        enum CodingKeys: String, CodingKey {
            case setNumber = "set_num"
            case name
            case year
            case themeID = "theme_id"
            case numberOfParts = "num_parts"
            case setImageURL = "set_img_url"
            case setURL = "set_url"
            case lastModifieDT = "last_modified_d"
        }
    }
}
