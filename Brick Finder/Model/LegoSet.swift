//
//  LegoSet.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 7/9/25.
//

import Foundation

struct LegoSet: Codable {
    // Rebrickable paginates the /sets/ endpoint. `count` is the total number of
    // sets matching the query, while `next`/`previous` are fully-formed URLs
    // (all query params + key + page already included) for walking the pages.
    let count: Int?
    let next: String?
    let previous: String?
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
