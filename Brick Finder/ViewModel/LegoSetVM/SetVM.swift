//
//  SetVM.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import Foundation

class SetVM: ObservableObject {
    @Published private(set) var isLoading = false
    /// Errors surfaced by list-level operations (search, getAllSets, themes, etc.).
    @Published private(set) var errorMessage: String?
    /// Errors surfaced by the Set Detail screen only. Kept separate so a transient
    /// detail-screen failure (or a cancellation from navigating back) cannot make
    /// the list view flash a "Couldn't load sets" banner.
    @Published private(set) var detailErrorMessage: String?
    
    @Published var searchText = ""
    @Published var themeId: String = "" {
        didSet {
            guard themeId != oldValue else { return }
            minYear = 0
            maxYear = 0
        }
    }
    @Published var maxYear = 0
    @Published var minYear = 0
    
    @Published var legoSetResults = [LegoSet.SetResults]()
    @Published var legoSet: [LegoSet.SetResults]?

    /// Total number of sets the API reports for the current filtered search
    /// (across all pages), so the UI can show "Showing X of N" if desired.
    @Published private(set) var setsTotalCount = 0
    /// True while an additional page of filtered sets is being appended.
    @Published private(set) var isLoadingMoreSets = false

    /// Fully-formed URL for the next page of the current filtered search, or nil
    /// when there are no more pages (or no active filtered search).
    private var nextSetsPageURL: String?

    /// Whether there are more sets left to fetch for the current search.
    var hasMoreSets: Bool { nextSetsPageURL != nil }
    @Published var legoSetMOCS: [LegoMOCS.LegoMOCSResult]?
    @Published var instructions: [Instructions.InstructionsResult]?
    @Published var setInfo: [SetInfo.Sets]?
    @Published var legoInstructions: Instructions.InstructionsResult?
    
    private let apiManager = RebrickableApi()
    private let brickableApiManager = BrickableAPI()
    private let searchCoordinator = SearchTaskCoordinator()

    /// Tracks the Phase 2 MOCs task so we can cancel a stale fetch when the user
    /// navigates to a different set or leaves the detail screen entirely.
    private var mocsTask: Task<Void, Never>?

    /// Returns true when an error represents user-driven cancellation (e.g. tapping
    /// Back while a request is in flight). These should never surface as UI errors.
    private static func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCancelled { return true }
        return false
    }

    @MainActor
    func clearListError() {
        errorMessage = nil
    }

    @MainActor
    func clearDetailError() {
        detailErrorMessage = nil
    }

    /// Loads the Set Detail screen dependencies concurrently (Brickable + Rebrickable + inventory).
    /// Call this from the view using `.task(id:)` so it cancels automatically when the set changes.
    func loadSetDetail(setNumber: String, inventoryVM: InventoryPartsVM) async {
        // Cancel any previous MOC fetch from a prior set before we start a new one.
        // Also wipe any detail state left over from a previously-viewed set so the
        // detail view doesn't render stale image/description/MOCs/inventory while
        // the new fetch is in flight (or if the new set has no extended info).
        await MainActor.run {
            mocsTask?.cancel()
            mocsTask = nil
            isLoading = true
            detailErrorMessage = nil
            setInfo = nil
            legoSetMOCS = nil
            inventoryVM.clearInventory()
        }

        // Phase 1: prioritize the Details tab (set info) + inventory.
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await inventoryVM.loadSetInventory(setNumber: setNumber)
            }

            group.addTask { [weak self] in
                guard let self else { return }
                do {
                    let info = try await self.brickableApiManager.getSet(setNumber: setNumber).sets
                    if Task.isCancelled { return }
                    await MainActor.run { self.setInfo = info }
                } catch {
                    if Task.isCancelled || Self.isCancellation(error) { return }
                    // Surface an empty state instead of a stuck ProgressView when
                    // the detail API has no info (or fails) for this set.
                    await MainActor.run {
                        self.detailErrorMessage = error.localizedDescription
                        self.setInfo = []
                    }
                }
            }
        }

        // Always clear the loading flag, even on cancellation. If we left it
        // stuck at `true` after the user navigated back, the SetsScreen would
        // show its full-screen ProgressView in place of the cached LazyVStack
        // and the ScrollView would lose its scroll position.
        await MainActor.run { isLoading = false }

        // If the parent task was cancelled (e.g. user navigated back), bail out
        // before kicking off the Phase 2 MOCs work — there's no detail view
        // left to display it.
        if Task.isCancelled {
            return
        }

        // Phase 2: load MOCs after the details are likely visible. Store the task
        // so that a back-navigation or a new set selection cancels it cleanly and
        // it cannot overwrite state on the now-detached detail view.
        await MainActor.run {
            self.mocsTask = Task { [weak self] in
                guard let self else { return }
                do {
                    let mocs = try await self.apiManager.getAlternateLegoSet(set: setNumber).results
                    if Task.isCancelled { return }
                    await MainActor.run { self.legoSetMOCS = mocs }
                } catch {
                    if Task.isCancelled || Self.isCancellation(error) { return }
                    await MainActor.run {
                        self.detailErrorMessage = error.localizedDescription
                        self.legoSetMOCS = []
                    }
                }
            }
        }
    }

    /// Cancels any in-flight detail-screen tasks. Call this from the detail view's
    /// `onDisappear` to make sure no late completion writes to the shared VM.
    @MainActor
    func cancelDetailLoading() {
        mocsTask?.cancel()
        mocsTask = nil
        // Also clear any detail-only error so it does not flash next time the
        // detail view is presented for a different set.
        detailErrorMessage = nil
    }
     
    var searchLegoSet: [LegoSet.SetResults]? {
        get { return getsearchResult() }
    }
    
    /// Primary search entry — keyboard submit and search bar actions should call this.
    @MainActor
    func submitSearch() {
        let query = SearchQueryNormalizer.normalizedForAPI(searchText)
        guard !query.isEmpty else { return }
        runFilteredSetSearch()
    }

    @MainActor
    func seacrhLegoSet() {
        submitSearch()
    }
    
    /// Loads instructions for a set number (e.g. from search). Trims whitespace; empty input clears results.
    @MainActor
    func getLegoIntructions(with setNumber: String) {
        let query = setNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            isLoading = false
            detailErrorMessage = nil
            instructions = nil
            return
        }
        
        isLoading = true
        detailErrorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.brickableApiManager.getInstructions(with: query).instructions
                await MainActor.run {
                    self.instructions = result
                    self.isLoading = false
                }
            } catch {
                if Self.isCancellation(error) {
                    await MainActor.run { self.isLoading = false }
                    return
                }
                print("Instructions load failed: \(error)")
                await MainActor.run {
                    self.detailErrorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    @MainActor
    func searchLegoSetWithTheme() {
        runFilteredSetSearch()
    }

    @MainActor
    func searchLegoSetWithAThemeAndYear() {
        runFilteredSetSearch()
    }

    @MainActor
    private func runFilteredSetSearch() {
        let query = SearchQueryNormalizer.normalizedForAPI(searchText)
        let signature = "sets|\(query)|\(themeId)|\(minYear)|\(maxYear)"

        let started = searchCoordinator.run(signature: signature) { [weak self] in
            guard let self else { return }
            await self.performFilteredSetSearch(query: query)
        }

        // Enter the loading state synchronously (before the async task hops to the
        // main actor) so the UI never renders an empty "Set not found" frame in
        // the gap between the filter change and the request starting.
        if started {
            isLoading = true
            errorMessage = nil
        }
    }

    @MainActor
    private func performFilteredSetSearch(query: String) async {
        isLoading = true
        errorMessage = nil

        // A brand-new search range invalidates any prior pagination state — wipe
        // it now so a stale "next" URL from the previous filter can't be used and
        // pagination effectively resets to page 1.
        nextSetsPageURL = nil
        setsTotalCount = 0
        isLoadingMoreSets = false

        do {
            let response: LegoSet
            if query.isEmpty {
                guard !themeId.isEmpty else {
                    isLoading = false
                    return
                }
                // Theme/year-only filters (no search text) — same routing as text search.
                response = try await fetchSets(searchTerm: "")
            } else {
                response = try await fetchSetsWithFallback(query: query)
            }
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            // First page replaces the list; capture the pagination cursor + total.
            // Sort chronologically so the list is year-ordered from the start.
            legoSetResults = Self.sortedChronologically(response.results)
            nextSetsPageURL = response.next
            setsTotalCount = response.count ?? response.results.count
            isLoading = false
        } catch {
            if Self.isCancellation(error) {
                isLoading = false
                return
            }
            print("No Result Found \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Mirrors `SearchQueryNormalizer.searchWithFallback`, but returns the full
    /// `LegoSet` response (not just `results`) so we keep the `next`/`count`
    /// pagination metadata for the page that actually produced results.
    private func fetchSetsWithFallback(query: String) async throws -> LegoSet {
        var lastResponse = LegoSet(count: nil, next: nil, previous: nil, results: [])
        for term in SearchQueryNormalizer.fallbackTerms(for: query) {
            try Task.checkCancellation()
            let response = try await fetchSets(searchTerm: term)
            if !response.results.isEmpty {
                return response
            }
            lastResponse = response
        }
        return lastResponse
    }

    /// Loads the next page of the current filtered search and appends it to the
    /// existing array. Triggered from the list's lazy-loading hook. Safe to call
    /// repeatedly — it no-ops while a fetch is in flight or once fully loaded.
    @MainActor
    func loadMoreSetsIfNeeded(currentItem: LegoSet.SetResults?) {
        guard let currentItem else {
            loadMoreSets()
            return
        }
        guard let index = legoSetResults.firstIndex(where: { $0.setNumber == currentItem.setNumber })
        else { return }

        // Pre-fetch a little before the very last row so the next page is ready
        // by the time the user reaches the bottom.
        let threshold = legoSetResults.index(
            legoSetResults.endIndex,
            offsetBy: -5,
            limitedBy: legoSetResults.startIndex
        ) ?? legoSetResults.startIndex

        if index >= threshold {
            loadMoreSets()
        }
    }

    @MainActor
    func loadMoreSets() {
        guard !isLoadingMoreSets, let nextURL = nextSetsPageURL else { return }
        isLoadingMoreSets = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await self.apiManager.getSetsPage(urlString: nextURL)
                await MainActor.run {
                    // Seamlessly append, then re-sort the ENTIRE collection so the
                    // chronological order holds across every fetched page (not just
                    // within each page). The LazyVStack keeps existing rows mounted.
                    var combined = self.legoSetResults
                    combined.append(contentsOf: page.results)
                    self.legoSetResults = Self.sortedChronologically(combined)
                    self.nextSetsPageURL = page.next
                    if let count = page.count { self.setsTotalCount = count }
                    self.isLoadingMoreSets = false
                }
            } catch {
                if Self.isCancellation(error) {
                    await MainActor.run { self.isLoadingMoreSets = false }
                    return
                }
                print("Failed to load more sets \(error)")
                await MainActor.run { self.isLoadingMoreSets = false }
            }
        }
    }

    /// LEGO's earliest sets date to 1949; used as the floor when the user has
    /// only chosen a "Year To" boundary.
    private static let earliestLegoYear = 1949

    /// The current calendar year, used as the ceiling when the user has only
    /// chosen a "Year From" boundary.
    private static var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    // MARK: - Theme ID grouping

    // Rebrickable splits some logical themes across multiple theme IDs. The
    // sets endpoint only accepts ONE `theme_id` per request (no comma lists),
    // so selecting the primary theme has to query each related ID and merge.
    private static let ninjagoThemeId = "435"           // "Ninjago" (parent)
    private static let ninjagoMovieThemeId = "616"      // "The LEGO Ninjago Movie"

    /// Maps a selected theme ID → every theme ID that should be queried for it.
    /// e.g. picking "Ninjago" also pulls in "The LEGO Ninjago Movie" sets.
    private static let themeIdGroups: [String: [String]] = [
        ninjagoThemeId: [ninjagoThemeId, ninjagoMovieThemeId]
    ]

    /// Returns the full list of theme IDs to query for a selected theme. Falls
    /// back to just the selected ID when it isn't part of a group.
    private static func themeIds(for selectedThemeId: String) -> [String] {
        themeIdGroups[selectedThemeId] ?? [selectedThemeId]
    }

    /// Resolves the active year window, defaulting whichever side the user hasn't
    /// picked. Returns nil when no year filter is active.
    ///   • "Year From" only → [chosenYear ... chosenYear]  (just that one year)
    ///   • "Year To" only   → [earliestLegoYear ... chosenMax]
    private func resolvedYearBounds() -> (min: Int, max: Int)? {
        let hasYearFilter = minYear != 0 || maxYear != 0
        guard hasYearFilter else { return nil }

        let chosenMin = minYear != 0 ? minYear : Self.earliestLegoYear
        // When only "Year From" is set, mirror it as the upper bound so results
        // are limited to that single year until a "Year To" is chosen.
        let chosenMax = maxYear != 0
            ? maxYear
            : (minYear != 0 ? minYear : Self.currentYear)

        // Guard against an inverted range (e.g. From 2020, To 2010) so the API
        // always receives lower ≤ upper and still returns results.
        return (min(chosenMin, chosenMax), max(chosenMin, chosenMax))
    }

    private func fetchSets(searchTerm: String) async throws -> LegoSet {
        // No theme selected → plain (paginated) search across all sets.
        guard !themeId.isEmpty else {
            return try await apiManager.seacrhAllLegoSets(with: searchTerm)
        }

        let ids = Self.themeIds(for: themeId)

        // Grouped theme (e.g. Ninjago + Ninjago Movie): fetch every page of each
        // ID concurrently, then merge them into a single de-duplicated, sorted
        // payload so no sets (like the 2017 movie sets) are missed.
        if ids.count > 1 {
            return try await fetchMergedThemeSets(themeIds: ids, searchTerm: searchTerm)
        }

        // Single theme → return the first page; infinite scroll loads the rest.
        return try await fetchThemeSetsPage(themeId: themeId, searchTerm: searchTerm)
    }

    /// Fetches the first page of sets for a single theme ID, honoring the active
    /// year window when present.
    private func fetchThemeSetsPage(themeId: String, searchTerm: String) async throws -> LegoSet {
        if let bounds = resolvedYearBounds() {
            return try await apiManager.searchLegoSetWithThemeAndYear(
                searchTerm: searchTerm,
                theme: themeId,
                minYear: Double(bounds.min),
                maxYear: Double(bounds.max)
            )
        }
        return try await apiManager.searchLegoSetWithTheme(
            searchTerm: searchTerm,
            theme: themeId
        )
    }

    /// Walks every page for a single theme ID (following the `next` cursor) and
    /// returns the complete set list for that theme.
    private func fetchAllThemeSets(themeId: String, searchTerm: String) async throws -> [LegoSet.SetResults] {
        var page = try await fetchThemeSetsPage(themeId: themeId, searchTerm: searchTerm)
        var all = page.results

        while let next = page.next {
            try Task.checkCancellation()
            page = try await apiManager.getSetsPage(urlString: next)
            all.append(contentsOf: page.results)
        }
        return all
    }

    /// Fetches all sets for each theme ID concurrently and merges them into one
    /// payload: de-duplicated by set number and sorted by set number. Pagination
    /// is collapsed (`next == nil`) because everything is loaded up front.
    private func fetchMergedThemeSets(themeIds ids: [String], searchTerm: String) async throws -> LegoSet {
        var merged: [LegoSet.SetResults] = []

        try await withThrowingTaskGroup(of: [LegoSet.SetResults].self) { group in
            for id in ids {
                group.addTask { [weak self] in
                    guard let self else { return [] }
                    return try await self.fetchAllThemeSets(themeId: id, searchTerm: searchTerm)
                }
            }
            for try await partial in group {
                merged.append(contentsOf: partial)
            }
        }

        let cleaned = Self.dedupedAndSorted(merged)
        return LegoSet(count: cleaned.count, next: nil, previous: nil, results: cleaned)
    }

    /// Removes duplicate sets (same set number), then orders them chronologically
    /// so the combined Ninjago + Movie list reads cleanly.
    private static func dedupedAndSorted(_ sets: [LegoSet.SetResults]) -> [LegoSet.SetResults] {
        var seen = Set<String>()
        var unique: [LegoSet.SetResults] = []
        unique.reserveCapacity(sets.count)

        for set in sets {
            // Keep sets without a number too, but never treat them as duplicates.
            guard let number = set.setNumber else {
                unique.append(set)
                continue
            }
            if seen.insert(number).inserted {
                unique.append(set)
            }
        }

        return sortedChronologically(unique)
    }

    /// Strict chronological ordering for the sets list: by `year` ascending, with
    /// `setNumber` as a stable secondary key so every year's sets stay uniform
    /// (e.g. all 2013 sets, then all 2014 sets, …). Sets missing a year sort last.
    private static func sortedChronologically(_ sets: [LegoSet.SetResults]) -> [LegoSet.SetResults] {
        sets.sorted { lhs, rhs in
            let lhsYear = lhs.year ?? Int.max
            let rhsYear = rhs.year ?? Int.max
            if lhsYear != rhsYear {
                return lhsYear < rhsYear
            }
            // Same year → keep a deterministic order by set number.
            return (lhs.setNumber ?? "") < (rhs.setNumber ?? "")
        }
    }
    
    @MainActor
    func getLegoSet() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                self.legoSet = try await apiManager.getAllLegoSet().results
                isLoading = false
            } catch {
                if Self.isCancellation(error) {
                    self.isLoading = false
                    return
                }
                print(error)
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getSetInfo(with params: String) {
        isLoading = true
        detailErrorMessage = nil
        Task {
            do {
                self.setInfo = try await brickableApiManager.getSet(setNumber: params).sets
                isLoading = false
            } catch {
                if Self.isCancellation(error) {
                    self.isLoading = false
                    return
                }
                self.detailErrorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getLegoSetWithTeme(themeId: String) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                self.legoSet = try await apiManager.getSetWithThemeId(themeId: themeId).results
                self.isLoading = false
            } catch {
                if Self.isCancellation(error) {
                    self.isLoading = false
                    return
                }
                print(error)
                self.errorMessage = error.localizedDescription
                self.legoSet = []
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getAlternateBuilds(with setNumber: String) {
        isLoading = true
        detailErrorMessage = nil
        Task {
            do {
                self.legoSetMOCS = try await apiManager.getAlternateLegoSet(set: setNumber).results
                isLoading = false
            } catch {
                if Self.isCancellation(error) {
                    self.isLoading = false
                    return
                }
                print(error)
                self.detailErrorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func getsearchResult() -> [LegoSet.SetResults] {
        legoSetResults
    }
}
