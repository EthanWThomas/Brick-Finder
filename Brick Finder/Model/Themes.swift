//
//  Themes.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 7/9/25.
//

import Foundation

struct Themes: Codable {
    
    let result: [ThemesResults]
    
    struct ThemesResults: Codable {
        
        let id: Int
        let pareentId: Int?
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case pareentId = "parent_id"
            case name
        }
    }
}
