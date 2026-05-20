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
    @Published var legoSetMOCS: [LegoMOCS.LegoMOCSResult]?
    @Published var instructions: [Instructions.InstructionsResult]?
    @Published var setInfo: [SetInfo.Sets]?
    @Published var legoInstructions: Instructions.InstructionsResult?
    
    private let apiManager = RebrickableApi()
    private let brickableApiManager = BrickableAPI()

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
    
    @MainActor
    func seacrhLegoSet() {
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await self.apiManager.seacrhAllLegoSets(with: self.searchText).results
                await MainActor.run {
                    self.isLoading = false
                    self.legoSetResults = results
                }
            } catch {
                if Self.isCancellation(error) { return }
                print("No Result Found \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
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
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await self.apiManager.searchLegoSetWithTheme(
                    searchTerm: self.searchText,
                    theme: self.themeId
                ).results
                await MainActor.run {
                    self.isLoading = false
                    self.legoSetResults = results
                }
            } catch {
                if Self.isCancellation(error) { return }
                print("No Result Found \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    
    @MainActor
    func searchLegoSetWithAThemeAndYear() {
        errorMessage = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await self.apiManager.searchLegoSetWithThemeAndYear(
                    searchTerm: self.searchText,
                    theme: self.themeId,
                    minYear: Double(self.minYear),
                    maxYear: Double(self.maxYear)
                ).results
                await MainActor.run {
                    self.isLoading = false
                    self.legoSetResults = results
                }
            } catch {
                if Self.isCancellation(error) { return }
                print("No Result Found \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
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
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return legoSetResults
        } else {
            return legoSetResults.filter { result in
                result.name?.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
    }
}
