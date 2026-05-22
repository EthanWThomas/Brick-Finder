//
//  SearchQueryNormalizer.swift
//  Brick Finder
//

import Foundation

enum SearchQueryNormalizer {
    /// Trims and collapses internal whitespace for API search terms.
    static func normalizedForAPI(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Percent-encodes a value for use in URL query parameters (e.g. spaces → `%20`).
    static func urlQueryEncoded(_ value: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "+&=")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }

    /// Ordered unique search terms to try when the primary query returns no results.
    static func fallbackTerms(for query: String) -> [String] {
        let normalized = normalizedForAPI(query)
        guard !normalized.isEmpty else { return [] }

        var terms: [String] = [normalized]

        let noSpaces = normalized.replacingOccurrences(of: " ", with: "")
        if noSpaces != normalized {
            terms.append(noSpaces)
        }

        let words = normalized.split(separator: " ").map(String.init)
        if words.count > 1 {
            for index in 0..<(words.count - 1) {
                var merged = words
                merged[index] = merged[index] + merged[index + 1]
                merged.remove(at: index + 1)
                terms.append(merged.joined(separator: " "))
            }

            for word in words.sorted(by: { $0.count > $1.count }) where word.count >= 3 {
                terms.append(word)
            }
        }

        var seen = Set<String>()
        return terms.filter { term in
            let key = term.lowercased()
            guard !seen.contains(key) else { return false }
            seen.insert(key)
            return true
        }
    }

    /// Runs `fetch` for each fallback term until results are returned or terms are exhausted.
    static func searchWithFallback<T>(
        query: String,
        fetch: (String) async throws -> [T]
    ) async throws -> [T] {
        for term in fallbackTerms(for: query) {
            try Task.checkCancellation()
            let results = try await fetch(term)
            if !results.isEmpty {
                return results
            }
        }
        return []
    }
}
