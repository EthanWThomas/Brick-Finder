//
//  SetInfo.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 2/7/26.
//

import Foundation

struct SetInfo: Codable {
    let sets: [Sets]
    
    struct Sets: Codable {
        let setID: Int?
        let number: String?
        let numberVariant: Int
        let name: String?
        let year: Int
        let theme: String?
        let themeGroup: String?
        let subTheme: String?
        let category: String?
        let released: Bool?
        let pleces: Int
        let minifigs: Int?
        let launchDate: String?
        let exitDate: String?
        let image: LegoImage?
        let legoCom: LegoCom?
        let rating: Double?
        let availability: String
        let instructionsCount: Int?
        let extendedData: ExtendedData?
        
        struct ExtendedData: Codable {
            let tags: [String]
            let description: String?
            
            enum CodingKeys: String, CodingKey {
                case tags
                case description = "description"
            }
        }
        
        struct LegoCom: Codable {
            let usa: LegoPrice
            
            struct LegoPrice: Codable {
                let retailPrice: Double
                let dateFirstAvailable: String
                let dateLastAvailable: String
            }
            
            enum CodingKeys: String, CodingKey {
                case usa = "US"
            }
        }
        
        struct LegoImage: Codable {
            let tumbnailURL: String?
            let imageURL: String?
        }
        
        enum CodingKeys: String, CodingKey {
            case setID = "setID"
            case number = "number"
            case numberVariant = "numberVariant"
            case name = "name"
            case year = "year"
            case theme = "theme"
            case themeGroup = "themeGroup"
            case subTheme = "subtheme"
            case category = "category"
            case released = "released"
            case pleces = "pieces"
            case minifigs = "minifigs"
            case launchDate = "launchDate"
            case exitDate = "exitDate"
            case image = "image"
            case legoCom = "LEGOCom"
            case rating = "rating"
            case availability = "availability"
            case instructionsCount = "instructionsCount"
            case extendedData = "extendedData"
        }
    }
}
