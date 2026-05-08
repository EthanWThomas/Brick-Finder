//
//  PartVM.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import Foundation

class PartVM: ObservableObject {
    
    @Published private(set) var isLoading = true
    /// Errors surfaced by list-level operations (search, getAllParts).
    @Published private(set) var errorMessage: String?
    /// Errors surfaced by the Part Detail screen only. Kept separate so a
    /// transient detail-screen failure (or a cancellation from navigating back)
    /// cannot make the list view flash a "Couldn't load parts" banner.
    @Published private(set) var detailErrorMessage: String?
    
    @Published var searchText = ""
    @Published var partId = ""
    
    @Published var legoPartsResult = [AllParts.PartResults]()
    @Published var part: [AllParts.PartResults]?
    @Published var colors: ColorCombination?
    @Published var legoPart: LegoParts?
    @Published var inventoryPart: [InventoryParts.PartResult]?
    @Published var partColor: [LegoColor.PartsAndColorResults]?
    @Published var legoSet: [LegoSet.SetResults]?
    
   
   private let apiManager = RebrickableApi()

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

    /// Clears any in-flight detail-screen error state. Call from the part detail
    /// view's `onDisappear` so a late completion can't flash an error in the list.
    @MainActor
    func cancelDetailLoading() {
        detailErrorMessage = nil
    }
    
    var searchLegoPart: [AllParts.PartResults]? {
        get { return getsearchResult() }
    }
    
    @MainActor
    func searchLegoParts() {
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await self.apiManager.searchParts(with: self.searchText).results
                await MainActor.run {
                    self.isLoading = false
                    self.legoPartsResult = results
                }
            } catch {
                if Self.isCancellation(error) {
                    await MainActor.run { self.isLoading = false }
                    return
                }
                print("No Result Found \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    @MainActor
    func searchLegoPartWithAPartId() {
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.apiManager.searchPartWithId(
                    part: self.partId,
                    searchTerm: self.searchText
                ).results
                await MainActor.run {
                    self.isLoading = false
                    self.legoPartsResult = result
                }
            } catch {
                if Self.isCancellation(error) {
                    await MainActor.run { self.isLoading = false }
                    return
                }
                print("No Result Found \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    @MainActor
    func getPart() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                self.part = try await apiManager.getPart().results
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
    func getminifigePart(figNumber: String) {
        isLoading = true
        detailErrorMessage = nil
        
        Task {
            do {
                self.inventoryPart = try await apiManager.getMinifigerInvetory(setNum: figNumber).results
                self.isLoading = false
            } catch {
                if Self.isCancellation(error) {
                    self.isLoading = false
                    return
                }
                print(error)
                detailErrorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getLegoPartsColor(part number: String) {
        isLoading = true
        detailErrorMessage = nil
        
        Task {
            do {
                self.partColor = try await apiManager.getListOfPartColor(part: number).results
                self.isLoading = false
            } catch {
                if Self.isCancellation(error) {
                    self.isLoading = false
                    return
                }
                print(error)
                detailErrorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getDetailAboutSpecificPart(partNumber: String) {
        isLoading = true
        detailErrorMessage = nil
        Task {
            do {
                self.legoPart = try await apiManager.getDetailAboutPart(part: partNumber)
                self.isLoading = false
            } catch {
                if Self.isCancellation(error) {
                    self.isLoading = false
                    return
                }
                print(error)
                detailErrorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getDetailsAboutPartAndColorCombination(partNumber: String, colorId: String) {
        isLoading = true
        detailErrorMessage = nil
        
        Task {
            do {
                self.colors = try await apiManager.getListOfPartCombinations(part: partNumber, color: colorId)
                self.isLoading = false
            } catch {
                if Self.isCancellation(error) {
                    self.isLoading = false
                    return
                }
                print(error)
                detailErrorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getListOfAllSetsPartAndColorCombination(partNumber: String, colorId: String) {
        isLoading = true
        detailErrorMessage = nil
        
        Task {
            do {
                self.legoSet = try await apiManager.getallSetThePartAndColorCombinationItHasApperadIn(part: partNumber, color: colorId).results
                self.isLoading = false
            } catch {
                if Self.isCancellation(error) {
                    self.isLoading = false
                    return
                }
                print(error)
                detailErrorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func getsearchResult() -> [AllParts.PartResults] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return legoPartsResult
        } else {
            return legoPartsResult.filter { result in
                result.name?.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
    }
}
