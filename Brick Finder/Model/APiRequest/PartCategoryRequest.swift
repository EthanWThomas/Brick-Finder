//
//  PartCategoryRequest.swift
//  Brick Finder
//

import Foundation

// MARK: - Rebrickable (paginated part categories list)

private struct RebrickablePartCategoriesPage: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [RebrickablePartCategoryRow]
}

private struct RebrickablePartCategoryRow: Decodable {
    let id: Int
    let name: String
}

extension RebrickableApi {
    /// `GET /api/v3/lego/part_categories/` — follows pagination until all categories are loaded.
    func fetchAllPartCategories() async throws -> [PartCategory] {
        var all: [PartCategory] = []
        var nextURL: URL? = URL(
            string: "https://rebrickable.com/api/v3/lego/part_categories/?page_size=1000&key=\(RebrickableApi.apiKey)"
        )

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        while let url = nextURL {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await URLSession.shared.data(for: request)

            switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200:
                let page = try decoder.decode(RebrickablePartCategoriesPage.self, from: data)
                all.append(contentsOf: page.results.map {
                    PartCategory(id: $0.id, name: $0.name)
                })
                nextURL = page.next.flatMap { URL(string: $0) }
            case 201, 204, 400, 401, 403, 404, 429:
                throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default:
                throw ResponseError.unownedErrorOccurred
            }
        }

        return all
    }
}
