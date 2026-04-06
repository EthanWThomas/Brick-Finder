//
//  Instructions.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 2/4/26.
//

import Foundation

struct Instructions: Codable {
    let instructions: [InstructionsResult]
    
    init(instructions: [InstructionsResult]) {
        self.instructions = instructions
    }
    
    struct InstructionsResult: Codable, Identifiable {
        let url: String?
        let description: String?
        let id: String
        
        enum CodingKeys: String, CodingKey {
            case url = "URL"
            case description
        }
        
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            url = try c.decodeIfPresent(String.self, forKey: .url)
            description = try c.decodeIfPresent(String.self, forKey: .description)
            id = url ?? description ?? UUID().uuidString
        }
        
        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encodeIfPresent(url, forKey: .url)
            try c.encodeIfPresent(description, forKey: .description)
        }
    }
}
