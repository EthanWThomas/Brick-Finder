//
//  GetLegoSetInfo.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 2/7/26.
//

import Foundation

extension BrickableAPI {
    func getSet(setNumber: String) async throws -> SetInfo {
        // 1. Create a Dictionary for your parameters
        let paramsDictionary = ["setNumber": setNumber]
        
        // 2. Convert that Dictionary into a JSON String
        let jsonData = try JSONEncoder().encode(paramsDictionary)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw RequestError.failedToCreateURL
        }
        
        // 3. Encode the string so it's safe for a URL (changes { } into %7B %7D)
        let encodedParams = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // 4. Build the URL using the encoded string
        let urlString = "https://brickset.com/api/v3.asmx/getSets?apiKey=\(BrickableAPI.apiKey)&userHash=&params=\(encodedParams)"
        
        guard let url = URL(string: urlString) else {
            throw RequestError.failedToCreateURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Handle response...
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(SetInfo.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
}
