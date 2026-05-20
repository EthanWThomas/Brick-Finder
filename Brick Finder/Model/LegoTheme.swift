//
//  LegoTheme.swift
//  Brick Finder
//

import Foundation

/// A LEGO theme from Rebrickable (`GET /api/v3/lego/themes/`).
struct LegoTheme: Codable, Identifiable, Hashable {
    let id: Int
    let parentId: Int?
    let name: String

    /// String id for `theme_id` / `in_theme_id` query parameters.
    var idString: String { String(id) }

    /// One picker row per theme name. Rebrickable returns parent and child themes that share a name.
    /// Prefers top-level themes (`parentId == nil`) so main categories like Star Wars (158) beat sub-themes.
    /// When both share the same parent level, keeps the lowest `id`.
    static func deduplicatedByName(_ themes: [LegoTheme]) -> [LegoTheme] {
        var bestByName: [String: LegoTheme] = [:]
        bestByName.reserveCapacity(themes.count)

        for theme in themes {
            let key = theme.name.lowercased()
            if let existing = bestByName[key] {
                if prefersThemeForDisplay(theme, over: existing) {
                    bestByName[key] = theme
                }
            } else {
                bestByName[key] = theme
            }
        }

        return Array(bestByName.values)
    }

    private static func prefersThemeForDisplay(_ candidate: LegoTheme, over existing: LegoTheme) -> Bool {
        let candidateIsRoot = candidate.parentId == nil
        let existingIsRoot = existing.parentId == nil
        if candidateIsRoot != existingIsRoot {
            return candidateIsRoot
        }
        return candidate.id < existing.id
    }

    /// Themes to always include in pickers when absent from the API/dedup pipeline.
    private static let manualOverrides: [LegoTheme] = [
        LegoTheme(id: 616, parentId: 435, name: "The LEGO NINJAGO Movie")
    ]

    /// Appends manual overrides after fetch/dedup when not already present (by id or name).
    static func withManualOverrides(_ themes: [LegoTheme]) -> [LegoTheme] {
        var result = themes
        for override in manualOverrides {
            let alreadyPresent = result.contains {
                $0.id == override.id
                    || $0.name.caseInsensitiveCompare(override.name) == .orderedSame
            }
            if !alreadyPresent {
                result.append(override)
            }
        }
        return result
    }
}

// MARK: - Disk cache

enum LegoThemeCache {
    private static let storageKey = "brickFinder.cachedLegoThemes.v1"
    private static let maxAge: TimeInterval = 7 * 24 * 60 * 60

    static func load() -> [LegoTheme]? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        guard !isExpired else {
            UserDefaults.standard.removeObject(forKey: storageKey)
            return nil
        }
        return try? JSONDecoder().decode([LegoTheme].self, from: data)
    }

    static func save(_ themes: [LegoTheme]) {
        guard let data = try? JSONEncoder().encode(themes) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "\(storageKey).savedAt")
    }

    private static var isExpired: Bool {
        let savedAt = UserDefaults.standard.double(forKey: "\(storageKey).savedAt")
        guard savedAt > 0 else { return true }
        return Date().timeIntervalSince1970 - savedAt > maxAge
    }
}
