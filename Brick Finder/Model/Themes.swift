//
//  Themes.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 7/9/25.
//

import Foundation

struct Themes: Codable {
    let themes: [ThemesResults]
    
    struct ThemesResults: Codable, Identifiable {
        let theme: String?
        let setCount: Int
        let subthemeCount: Int
        let yearFrom: Int?
        let yearTo: Int?
        /// Stable id for SwiftUI lists (Rebrickable theme id as string, or UUID for Brickset-only rows).
        var id: String
        
        enum CodingKeys: String, CodingKey {
            case theme
            case setCount
            case subthemeCount
            case yearFrom
            case yearTo
        }
        
        init(theme: String?, setCount: Int, subthemeCount: Int, yearFrom: Int?, yearTo: Int?, id: String) {
            self.theme = theme
            self.setCount = setCount
            self.subthemeCount = subthemeCount
            self.yearFrom = yearFrom
            self.yearTo = yearTo
            self.id = id
        }
        
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            theme = try c.decodeIfPresent(String.self, forKey: .theme)
            setCount = try c.decodeIfPresent(Int.self, forKey: .setCount) ?? 0
            subthemeCount = try c.decodeIfPresent(Int.self, forKey: .subthemeCount) ?? 0
            yearFrom = try c.decodeIfPresent(Int.self, forKey: .yearFrom)
            yearTo = try c.decodeIfPresent(Int.self, forKey: .yearTo)
            id = UUID().uuidString
        }
    }
}

//"theme": "4 Juniors",
//"setCount": 24,
//"subthemeCount": 5,
//"yearFrom": 2003,
//"yearTo": 2004
