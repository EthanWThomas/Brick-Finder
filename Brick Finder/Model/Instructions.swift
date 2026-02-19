//
//  Instructions.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 2/4/26.
//

import Foundation

struct Instructions: Codable {
    let instructions: [InstructionsResult]
    
    struct InstructionsResult: Codable {
        let url: String?
        let description: String?
        var id = UUID().uuidString
        
        enum CodingKeys: String, CodingKey {
            case url = "URL"
            case description = "description"
        }
    }
}
