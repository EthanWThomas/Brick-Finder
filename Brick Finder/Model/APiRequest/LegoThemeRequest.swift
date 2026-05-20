//
//  LegoThemeRequest.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 3/17/26.
//

import Foundation

// MARK: - Rebrickable (paginated themes list)

private struct RebrickableThemesPage: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [RebrickableThemeRow]
}

private struct RebrickableThemeRow: Decodable {
    let id: Int
    let parentId: Int?
    let name: String
}

extension RebrickableApi {
    /// `GET /api/v3/lego/themes/` — follows pagination until all themes are loaded.
    func fetchAllLegoThemes() async throws -> [LegoTheme] {
        var all: [LegoTheme] = []
        var nextURL: URL? = URL(
            string: "https://rebrickable.com/api/v3/lego/themes/?page_size=1000&key=\(RebrickableApi.apiKey)"
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
                let page = try decoder.decode(RebrickableThemesPage.self, from: data)
                all.append(contentsOf: page.results.map {
                    LegoTheme(id: $0.id, parentId: $0.parentId, name: $0.name)
                })
                nextURL = page.next.flatMap { URL(string: $0) }
            case 201, 204, 400, 401, 403, 404, 429:
                throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default:
                throw ResponseError.unownedErrorOccurred
            }
        }

        return LegoTheme.withManualOverrides(LegoTheme.deduplicatedByName(all))
    }
}

// MARK: - Brickset (optional; different JSON shape than Rebrickable)

/// Brickset wraps JSON with `status` / `message`. Invalid keys can still return HTTP 200.
private struct BricksetThemesEnvelope: Decodable {
    let status: String?
    let message: String?
    let themes: [Themes.ThemesResults]?
}

extension BrickableAPI {
    func getAllLegoThemeFromBrickset() async throws -> Themes {
        guard let url = URL(string: "https://brickset.com/api/v3.asmx/getThemes?apiKey=\(BrickableAPI.apiKey)")
        else { throw RequestError.failedToCreateURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
        case 200:
            let envelope = try JSONDecoder().decode(BricksetThemesEnvelope.self, from: data)
            if envelope.status == "error" {
                throw NSError(
                    domain: "Brickset",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: envelope.message ?? "Brickset API error"]
                )
            }
            guard let list = envelope.themes else {
                throw NSError(
                    domain: "Brickset",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: envelope.message ?? "No themes in response"]
                )
            }
            return Themes(themes: list)
        case 201, 204, 400, 401, 403, 404, 429:
            throw try JSONDecoder().decode(ErrorResponse.self, from: data)
        default:
            throw ResponseError.unownedErrorOccurred
        }
    }
}
