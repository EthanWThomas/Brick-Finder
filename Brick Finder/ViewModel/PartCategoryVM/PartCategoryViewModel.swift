//
//  PartCategoryViewModel.swift
//  Brick Finder
//

import Foundation

@MainActor
final class PartCategoryViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var categories: [PartCategory] = []

    /// Alphabetical list for pickers and sheets.
    var sortedCategories: [PartCategory] {
        categories.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    /// Curated set of the most commonly browsed LEGO part categories, matched
    /// against the Rebrickable `name` (case-insensitive). These float to a
    /// "Popular Categories" section at the top of the picker so users don't have
    /// to scroll past dozens of niche categories to reach the everyday ones.
    ///
    /// Stored lowercased so lookups are a cheap, case-insensitive `Set` hit.
    static let popularCategoryNames: Set<String> = [
        "bricks",
        "plates",
        "tiles",
        "technic",
        "slopes",
        "bricks sloped",
        "minifigs",
        "wheels and tyres",
        "plants and animals",
        "baseplates",
        "windows and doors",
        "bricks round and cones"
    ]

    /// True when a category is part of our curated "popular" list.
    private func isPopular(_ category: PartCategory) -> Bool {
        Self.popularCategoryNames.contains(category.name.lowercased())
    }

    /// Curated, commonly browsed categories only — alphabetical.
    var popularCategories: [PartCategory] {
        sortedCategories.filter(isPopular)
    }

    /// Every remaining (non-popular) category — alphabetical.
    var otherCategories: [PartCategory] {
        sortedCategories.filter { !isPopular($0) }
    }

    /// A single A–Z bucket for the category browser (e.g. "B" with every
    /// category that starts with "B"). `id`/`title` is the section letter; the
    /// catch-all "#" bucket holds names that don't begin with a letter.
    struct CategoryAlphabetSection: Identifiable {
        let id: String
        let categories: [PartCategory]
        var title: String { id }
    }

    /// The non-popular categories grouped by starting letter, A→Z, with the
    /// non-letter "#" bucket sorted last. Because the input (`otherCategories`)
    /// is already alphabetical, every section's contents stay alphabetical too.
    var alphabeticalSections: [CategoryAlphabetSection] {
        let grouped = Dictionary(grouping: otherCategories) { category -> String in
            guard let first = category.name.first, first.isLetter else { return "#" }
            return String(first).uppercased()
        }

        return grouped
            .map { CategoryAlphabetSection(id: $0.key, categories: $0.value) }
            .sorted { lhs, rhs in
                // Letters first (A→Z); the "#" catch-all always trails the end.
                if lhs.id == "#" { return false }
                if rhs.id == "#" { return true }
                return lhs.id < rhs.id
            }
    }

    private let rebrickable = RebrickableApi()
    private var loadTask: Task<Void, Never>?

    /// Loads from disk cache immediately when available, then refreshes from Rebrickable.
    func loadCategoriesIfNeeded() {
        guard loadTask == nil else { return }
        loadTask = Task { await loadCategories() }
    }

    func loadCategories() async {
        if let cached = PartCategoryCache.load() {
            categories = cached
            isLoading = false
        } else {
            isLoading = true
        }
        errorMessage = nil

        do {
            let fetched = try await rebrickable.fetchAllPartCategories()
            categories = fetched
            PartCategoryCache.save(fetched)
            isLoading = false
            errorMessage = nil
        } catch {
            if categories.isEmpty {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func category(withIdString id: String) -> PartCategory? {
        guard let intId = Int(id) else { return nil }
        return categories.first { $0.id == intId }
    }
}
