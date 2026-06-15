//
//  InventoryPartsVM.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import Foundation

class InventoryPartsVM: ObservableObject {
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?
    @Published var setNumber = ""
    
    @Published var setInventoryPart: [InventoryParts.PartResult]?
    @Published var getInventoryMinifiger: [Lego.LegoResults]?
    @Published var inventoryPartResults = [InventoryParts.PartResult]()

    /// Total number of parts the API reports for the current set (across all
    /// pages), so the UI can show "Showing X of N".
    @Published private(set) var partsTotalCount = 0
    /// True while an additional page of parts is being appended.
    @Published private(set) var isLoadingMoreParts = false

    /// Fully-formed URL for the next page of parts, or nil when we've loaded
    /// everything for the current set.
    private var nextPartsPageURL: String?

    /// Whether there are more parts left to fetch for the current set.
    var hasMoreParts: Bool { nextPartsPageURL != nil }
    
    private let apiManager = RebrickableApi()
    
    var searchLegoSetInventory: [InventoryParts.PartResult] { getsearchResult() }
    
    @MainActor
    func searchPartNumber() {
        isLoading = true
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await self.apiManager.getInvetoryPartInASet(setNum: self.setNumber)
                await MainActor.run {
                    self.isLoading = false
                    self.inventoryPartResults = page.results
                    self.setInventoryPart = page.results
                    self.nextPartsPageURL = page.next
                    self.partsTotalCount = page.count ?? page.results.count
                }
            } catch {
                print("No Result Found \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func getInventoryPart(with setNumber: String) {
        Task {
            await loadSetInventory(setNumber: setNumber, includeMinifigs: false)
        }
    }
    
    func getInventoryMinifigerInSet(with setNumber: String) {
        Task {
            await loadSetInventory(setNumber: setNumber, includeParts: false)
        }
    }

    /// Clears the cached parts + minifig inventory. Call this when navigating to a
    /// new set so the detail screen doesn't render the previously-viewed set's
    /// inventory while a fresh fetch is in flight.
    @MainActor
    func clearInventory() {
        setInventoryPart = nil
        getInventoryMinifiger = nil
        errorMessage = nil
        nextPartsPageURL = nil
        partsTotalCount = 0
        isLoadingMoreParts = false
    }

    /// Lazy-loading hook for grids/lists: call from each part row's `.onAppear`.
    /// When the row is near the end of what we've loaded, it kicks off a fetch
    /// of the next page so scrolling feels seamless.
    @MainActor
    func loadMorePartsIfNeeded(currentItem: InventoryParts.PartResult?) {
        guard let currentItem else {
            loadMoreParts()
            return
        }
        guard let parts = setInventoryPart,
              let index = parts.firstIndex(where: { $0.id == currentItem.id })
        else { return }

        // Trigger a little before the very last item so the next page is ready
        // by the time the user scrolls to it.
        let threshold = parts.index(parts.endIndex, offsetBy: -5, limitedBy: parts.startIndex) ?? parts.startIndex
        if index >= threshold {
            loadMoreParts()
        }
    }

    /// Fetches the next page of parts (if any) and appends it to the existing
    /// published array. Safe to call repeatedly — overlapping/duplicate calls
    /// are ignored while a fetch is in flight or once everything is loaded.
    @MainActor
    func loadMoreParts() {
        guard !isLoadingMoreParts, let nextURL = nextPartsPageURL else { return }
        isLoadingMoreParts = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await self.apiManager.getInventoryPartsPage(urlString: nextURL)
                await MainActor.run {
                    var current = self.setInventoryPart ?? []
                    current.append(contentsOf: page.results)
                    self.setInventoryPart = current
                    self.inventoryPartResults = current
                    self.nextPartsPageURL = page.next
                    if let count = page.count { self.partsTotalCount = count }
                    self.isLoadingMoreParts = false
                }
            } catch {
                print("Failed to load more parts \(error)")
                await MainActor.run {
                    self.isLoadingMoreParts = false
                }
            }
        }
    }

    /// Loads inventory parts + minifigs concurrently for a set.
    /// Use this from a parent loader (e.g. `SetVM`) to avoid multiple overlapping Tasks.
    func loadSetInventory(setNumber: String, includeParts: Bool = true, includeMinifigs: Bool = true) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            // Wipe any prior set's inventory so we don't show stale data
            // (e.g. parts from the previously-viewed set) under the loading
            // indicator before the new fetch lands.
            if includeParts {
                setInventoryPart = nil
            }
            if includeMinifigs {
                getInventoryMinifiger = nil
            }
        }

        do {
            let partsResponse: InventoryParts?
            let minifigsResult: [Lego.LegoResults]?

            switch (includeParts, includeMinifigs) {
            case (true, true):
                async let partsData = try await apiManager.getInvetoryPartInASet(setNum: setNumber)
                async let minifigsData = try await apiManager.getInvetoryMinifigerInASet(with: setNumber)
                let (p, m) = try await (partsData, minifigsData)
                partsResponse = p
                minifigsResult = m.results
            case (true, false):
                partsResponse = try await apiManager.getInvetoryPartInASet(setNum: setNumber)
                minifigsResult = nil
            case (false, true):
                let m = try await apiManager.getInvetoryMinifigerInASet(with: setNumber)
                partsResponse = nil
                minifigsResult = m.results
            case (false, false):
                partsResponse = nil
                minifigsResult = nil
            }

            await MainActor.run {
                if includeParts {
                    let firstPage = partsResponse?.results ?? []
                    setInventoryPart = firstPage
                    inventoryPartResults = firstPage
                    nextPartsPageURL = partsResponse?.next
                    partsTotalCount = partsResponse?.count ?? firstPage.count
                }
                if includeMinifigs {
                    getInventoryMinifiger = minifigsResult
                }
                isLoading = false
            }
        } catch {
            print(error)
            await MainActor.run {
                errorMessage = error.localizedDescription
                // Surface an empty state instead of a stuck ProgressView when
                // the inventory API fails for this set.
                if includeParts {
                    setInventoryPart = []
                    inventoryPartResults = []
                    nextPartsPageURL = nil
                    partsTotalCount = 0
                }
                if includeMinifigs {
                    getInventoryMinifiger = []
                }
                isLoading = false
            }
        }
    }
    
    func getsearchResult() -> [InventoryParts.PartResult] {
        if setNumber.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return inventoryPartResults
        } else {
            return inventoryPartResults.filter { result in
                result.part.partNumber?.range(of: setNumber, options: .caseInsensitive) != nil
            }
        }
    }
}
