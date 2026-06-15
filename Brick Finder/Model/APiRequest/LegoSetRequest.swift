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
        let encoded = SearchQueryNormalizer.urlQueryEncoded(searchTerm)
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/?search=\(encoded)&key=\(RebrickableApi.apiKey)")
        else { throw RequestError.failedToCreateURL }
        
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
        let encoded = SearchQueryNormalizer.urlQueryEncoded(searchTerm)
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/?theme_id=\(theme)&search=\(encoded)&key=\(RebrickableApi.apiKey)")
        else { throw RequestError.failedToCreateURL }
        
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
        let encoded = SearchQueryNormalizer.urlQueryEncoded(searchTerm)
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/?theme_id=\(theme)&min_year=\(minYear)&max_year=\(maxYear)&search=\(encoded)&key=\(RebrickableApi.apiKey)")
        else { throw RequestError.failedToCreateURL }
        
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
        else { throw RequestError.failedToCreateURL }
        
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
        else { throw RequestError.failedToCreateURL }
        
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
    
    // MARK: get all sets with a theme
    func getSetWithThemeId(themeId: String) async throws -> LegoSet {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/?theme_id=\(themeId)&key=\(RebrickableApi.apiKey)")
        else { throw RequestError.failedToCreateURL }
        
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
                
        else { throw RequestError.failedToCreateURL }
        
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
    /// Fetches one page of a set's inventory parts. Rebrickable caps each
    /// response (default 100, max 1000 per page) so callers should keep
    /// following the `next` URL on the returned `InventoryParts` until it's nil.
    func getInvetoryPartInASet(setNum: String, page: Int = 1, pageSize: Int = 100) async throws -> InventoryParts {
        guard let url = URL(string: "https://rebrickable.com/api/v3/lego/sets/\(setNum)/parts/?page=\(page)&page_size=\(pageSize)&key=\(RebrickableApi.apiKey)")
                
        else { throw RequestError.failedToCreateURL }
        
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

    // MARK: - Fetch a specific inventory-parts page by its pagination URL
    /// Loads the next page of inventory parts directly from the `next` URL that
    /// Rebrickable returns. That URL already contains the API key and paging
    /// parameters, so we just request it as-is.
    func getInventoryPartsPage(urlString: String) async throws -> InventoryParts {
        guard let url = URL(string: urlString)
        else { throw RequestError.failedToCreateURL }
        
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
                
        else { throw RequestError.failedToCreateURL }
        
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
