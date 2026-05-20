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
