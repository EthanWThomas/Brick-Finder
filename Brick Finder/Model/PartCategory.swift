//
//  PartCategory.swift
//  Brick Finder
//

import Foundation

/// A LEGO part category from Rebrickable (`GET /api/v3/lego/part_categories/`).
struct PartCategory: Codable, Identifiable, Hashable {
    let id: Int
    let name: String

    /// String id for `part_cat_id` query parameters.
    var idString: String { String(id) }
}

// MARK: - Disk cache

enum PartCategoryCache {
    private static let storageKey = "brickFinder.cachedPartCategories.v1"
    private static let maxAge: TimeInterval = 7 * 24 * 60 * 60

    static func load() -> [PartCategory]? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        guard !isExpired else {
            UserDefaults.standard.removeObject(forKey: storageKey)
            return nil
        }
        return try? JSONDecoder().decode([PartCategory].self, from: data)
    }

    static func save(_ categories: [PartCategory]) {
        guard let data = try? JSONEncoder().encode(categories) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "\(storageKey).savedAt")
    }

    private static var isExpired: Bool {
        let savedAt = UserDefaults.standard.double(forKey: "\(storageKey).savedAt")
        guard savedAt > 0 else { return true }
        return Date().timeIntervalSince1970 - savedAt > maxAge
    }
}
