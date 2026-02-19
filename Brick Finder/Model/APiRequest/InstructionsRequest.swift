//
//  InstructionsRequest.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 2/4/26.
//

import Foundation

extension BrickableAPI {
    
    // MARK: Get all lego set Instructions.
    func getInstructions(with setNumber: String) async throws -> Instructions {
        guard let url = URL(string: "https://brickset.com/api/v3.asmx/getInstructions2?apiKey=\(BrickableAPI.apiKey)&setNumber=\(setNumber)")
        else { throw RequestError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "No data received")
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(Instructions.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
                
        }
        
    }
    
}
