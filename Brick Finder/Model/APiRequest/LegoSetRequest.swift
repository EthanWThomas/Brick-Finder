//
//  LegoSetRequest.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/5/25.
//

import Foundation

extension RebrickableApi {
    
    // MARK: Search for all lego sets
    func seacrhAllLegoSets(with searchTerm: String) async throws -> LegoSet {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/?search=\(searchTerm)&key=\(RebrickableApi.apiKey)")
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
    
    // MARK: - Search all Lego sets with a theme
    func searchLegoSetWithTheme(searchTerm: String, theme: String) async throws -> LegoSet {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/?theme_id=\(theme)&search=\(searchTerm)&key=\(RebrickableApi.apiKey)")
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
    
    // MARK: - Search all Lego sets with a theme and year
    func searchLegoSetWithThemeAndYear(
        searchTerm: String,
        theme: String,
        minYear: Double,
        maxYear: Double
    ) async throws -> LegoSet {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/?theme_id=\(theme)&min_year=\(minYear)&max_year=\(maxYear)&search=\(searchTerm)&key=\(RebrickableApi.apiKey)")
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
    
    // MARK: - Get All Lego Seta
    func getAllLegoSet() async throws -> LegoSet {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/?key=\(RebrickableApi.apiKey)")
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
    
    // MARK: - Get Specific Set
    func getSpecificSet(with setNumber: String) async throws -> LegoSet {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/\(setNumber)?key=\(RebrickableApi.apiKey)")
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
    
    // MARK: - Get a list of MOCs which are Alternate Builds of a specific Set - i.e. all parts in the MOC can be found in the Set.
    func getAlternateLegoSet(set number: String) async throws -> LegoMOCS {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/\(number)/alternates/?key=\(RebrickableApi.apiKey)")
                
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(LegoMOCS.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    // MARK: - Get a list of all Inventory Parts in this Set
    func getInvetoryPartInASet(setNum: String) async throws -> InventoryParts {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/\(setNum)/parts/?key=\(RebrickableApi.apiKey)")
                
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(InventoryParts.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    // MARK: - Get a list of all Inventory Minifigs in this Set.
    func getInvetoryMinifigerInASet(with setNumber: String) async throws -> Lego {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/\(setNumber)/minifigs/?key=\(RebrickableApi.apiKey)")
                
        else { throw RequstError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(Lego.self, from: data)
            case 201, 204, 400, 401, 403, 404, 429: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
}
