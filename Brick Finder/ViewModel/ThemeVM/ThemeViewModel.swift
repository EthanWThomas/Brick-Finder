//
//  ThemeViewModel.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 3/17/26.
//

import Foundation

@MainActor
final class ThemeViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var themes: [LegoTheme] = []

    /// Alphabetical, name-unique list for pickers and sheets.
    var sortedThemes: [LegoTheme] {
        LegoTheme.deduplicatedByName(themes).sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    /// Curated set of universally recognizable LEGO themes, matched against the
    /// Rebrickable `name` (case-insensitive). These are surfaced in a "Popular
    /// Themes" section at the top of the picker so users don't have to scroll
    /// past hundreds of obscure, niche themes to reach the classics.
    ///
    /// Stored lowercased so lookups are a cheap, case-insensitive `Set` hit.
    static let popularThemeNames: Set<String> = [
        "star wars",
        "harry potter",
        "city",
        "ninjago",
        "technic",
        "marvel super heroes",
        "batman",
        "creator",
        "icons",
        "friends",
        "speed champions",
        "super mario",
        "minecraft",
        "ideas",
        "architecture",
        "disney",
        "duplo"
    ]

    /// True when a theme is part of our curated "popular" list.
    private func isPopular(_ theme: LegoTheme) -> Bool {
        Self.popularThemeNames.contains(theme.name.lowercased())
    }

    /// Curated, highly recognizable themes only — alphabetical.
    /// Derived from `sortedThemes`, so it inherits dedup + alphabetical order.
    var popularThemes: [LegoTheme] {
        sortedThemes.filter(isPopular)
    }

    /// Every remaining (non-popular) theme — alphabetical.
    var otherThemes: [LegoTheme] {
        sortedThemes.filter { !isPopular($0) }
    }

    private let rebrickable = RebrickableApi()
    private var loadTask: Task<Void, Never>?

    /// Loads from disk cache immediately when available, then refreshes from Rebrickable.
    func loadThemesIfNeeded() {
        guard loadTask == nil else { return }
        loadTask = Task { await loadThemes() }
    }

    func loadThemes() async {
        if let cached = LegoThemeCache.load() {
            themes = LegoTheme.withManualOverrides(LegoTheme.deduplicatedByName(cached))
            isLoading = false
        } else {
            isLoading = true
            themes = []
        }
        errorMessage = nil

        do {
            let fetched = try await rebrickable.fetchAllLegoThemes()
            themes = fetched
            LegoThemeCache.save(fetched)
            isLoading = false
            errorMessage = nil
        } catch {
            if themes.isEmpty {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func theme(withIdString id: String) -> LegoTheme? {
        guard let intId = Int(id) else { return nil }
        return themes.first { $0.id == intId }
    }
}
