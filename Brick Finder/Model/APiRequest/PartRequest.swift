//
//  PartRequest.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/5/25.
//

import Foundation

extension RebrickableApi {
    
    // MARK: - Sesrch all lego parts
    func searchParts(with searchTerm: String) async throws -> AllParts {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/parts/?search=\(searchTerm)&key=\(RebrickableApi.apiKey)")
                
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(AllParts.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    // MARK: - Get all lego parts from the api
    func getPart() async throws -> AllParts {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/parts/?key=\(RebrickableApi.apiKey)")
                
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(AllParts.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    // MARK: - Get Seacrh Part with id
    func searchPartWithId(part id: String, searchTerm: String) async throws -> AllParts {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/parts/?part_cat_id=\(id)&search=\(searchTerm)&key=\(RebrickableApi.apiKey)")
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(AllParts.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
                
    }
    
    // MARK: - Get a list of all Colors a Part has appeared
    // Get a list of all Colors a Part has appeared
    func getListOfAllColorAndPart(partNum: String) async throws -> PartsAndColor {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/parts/\(partNum)/colors/?key=\(RebrickableAPI.apiKey)")
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(PartsAndColor.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    // MARK: - Get a list of all Sets the Part/Color combination has appeard in.
    func getallSetThePartAndColorCombinationItHasApperadIn(part number: String, color id: String) async throws -> LegoSet {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/parts/\(number)/colors/\(id)/sets/?key=\(RebrickableAPI.apiKey)")
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(LegoSet.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    // MARK: Return all Themes
    func returnAllThemes() async throws -> Themes {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/themes/?key=\(RebrickableAPI.apiKey)")
                
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(Themes.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
}
