//
//  RebrickableRequest.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/3/25.
//

import Foundation

extension RebrickableApi {
    
    func searchMinfigs(with searchTerm: String) async throws -> Lego {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/minifigs/?search=\(searchTerm)&key=\(RebrickableApi.apiKey)")
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(Lego.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    func getMinifig() async throws -> Lego {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/minifigs/?key=\(RebrickableApi.apiKey)")
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(Lego.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    func getAllMinifigsSetCameIn(setNumber: String) async throws -> Lego {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/minifigs/\(setNumber)/sets/?key=\(RebrickableApi.apiKey)")
        else { throw RequstError.failedToCreateURL }
        
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(Lego.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    func getMinifigerInvetory(setNum: String) async throws -> InventoryParts {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/minifigs/\(setNum)/parts/?key=\(RebrickableApi.apiKey)")
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(InventoryParts.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
}
