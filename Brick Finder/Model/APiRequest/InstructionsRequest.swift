//
//  InstructionsRequest.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 2/4/26.
//

import Foundation

extension BrickableAPI {
    
    /// Brickset wraps payloads in `status` / `message`; error responses are still HTTP 200 with no `instructions` key.
    private struct BricksetInstructionsEnvelope: Decodable {
        let status: String?
        let message: String?
        let instructions: [Instructions.InstructionsResult]?
    }
    
    // MARK: Get all lego set Instructions.
    func getInstructions(with setNumber: String) async throws -> Instructions {
        var components = URLComponents(string: "https://brickset.com/api/v3.asmx/getInstructions2")
        components?.queryItems = [
            URLQueryItem(name: "apiKey", value: BrickableAPI.apiKey),
            URLQueryItem(name: "setNumber", value: setNumber)
        ]
        guard let url = components?.url else { throw RequestError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("BrickFinder/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let raw = String(data: data, encoding: .utf8) {
            print("Brickset getInstructions2: \(raw.prefix(500))")
        }
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard statusCode == 200 else {
            throw ResponseError.httpStatus(code: statusCode)
        }
        
        let decoder = JSONDecoder()
        let envelope = try decoder.decode(BricksetInstructionsEnvelope.self, from: data)
        
        if envelope.status == "error" {
            throw BricksetInstructionsAPIError.bricksetMessage(envelope.message ?? "Unknown Brickset error.")
        }
        
        return Instructions(instructions: envelope.instructions ?? [])
    }
    
}
