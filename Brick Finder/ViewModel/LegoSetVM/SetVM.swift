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

        searchCoordinator.run(signature: signature) { [weak self] in
            guard let self else { return }
            await self.performFilteredSetSearch(query: query)
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
            legoSetResults = response.results
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
                    // Seamlessly append; the LazyVStack keeps existing rows mounted
                    // so the user's scroll position is preserved.
                    self.legoSetResults.append(contentsOf: page.results)
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

    private func fetchSets(searchTerm: String) async throws -> LegoSet {
        // A year filter is active as soon as EITHER boundary is set — we no
        // longer wait for both to be filled in.
        let hasYearFilter = minYear != 0 || maxYear != 0

        if !themeId.isEmpty, hasYearFilter {
            // Default whichever side the user hasn't picked yet so a one-sided
            // selection still produces a valid range:
            //   • "Year From" only  → [chosenYear ... chosenYear]  (just that one year)
            //   • "Year To" only    → [earliestLegoYear ... chosenMax]
            // Picking the second boundary later expands it into the full range.
            let chosenMin = minYear != 0 ? minYear : Self.earliestLegoYear
            // When only "Year From" is set, mirror it as the upper bound so the
            // results are limited to that single year until a "Year To" is chosen.
            let chosenMax = maxYear != 0
                ? maxYear
                : (minYear != 0 ? minYear : Self.currentYear)

            // Guard against an inverted range (e.g. From 2020, To 2010) so the
            // API always receives lower ≤ upper and still returns results.
            let lowerYear = min(chosenMin, chosenMax)
            let upperYear = max(chosenMin, chosenMax)

            return try await apiManager.searchLegoSetWithThemeAndYear(
                searchTerm: searchTerm,
                theme: themeId,
                minYear: Double(lowerYear),
                maxYear: Double(upperYear)
            )
        }
        if !themeId.isEmpty {
            return try await apiManager.searchLegoSetWithTheme(
                searchTerm: searchTerm,
                theme: themeId
            )
        }
        return try await apiManager.seacrhAllLegoSets(with: searchTerm)
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
