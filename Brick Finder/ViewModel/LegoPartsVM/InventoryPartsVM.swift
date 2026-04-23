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
    
    private let apiManager = RebrickableApi()
    
    var searchLegoSetInventory: [InventoryParts.PartResult] { getsearchResult() }
    
    @MainActor
    func searchPartNumber() {
        isLoading = true
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await self.apiManager.getInvetoryPartInASet(setNum: self.setNumber).results
                await MainActor.run {
                    self.isLoading = false
                    self.inventoryPartResults = results
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

    /// Loads inventory parts + minifigs concurrently for a set.
    /// Use this from a parent loader (e.g. `SetVM`) to avoid multiple overlapping Tasks.
    func loadSetInventory(setNumber: String, includeParts: Bool = true, includeMinifigs: Bool = true) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let partsResult: [InventoryParts.PartResult]?
            let minifigsResult: [Lego.LegoResults]?

            switch (includeParts, includeMinifigs) {
            case (true, true):
                async let partsData = try await apiManager.getInvetoryPartInASet(setNum: setNumber)
                async let minifigsData = try await apiManager.getInvetoryMinifigerInASet(with: setNumber)
                let (p, m) = try await (partsData, minifigsData)
                partsResult = p.results
                minifigsResult = m.results
            case (true, false):
                let p = try await apiManager.getInvetoryPartInASet(setNum: setNumber)
                partsResult = p.results
                minifigsResult = nil
            case (false, true):
                let m = try await apiManager.getInvetoryMinifigerInASet(with: setNumber)
                partsResult = nil
                minifigsResult = m.results
            case (false, false):
                partsResult = nil
                minifigsResult = nil
            }

            await MainActor.run {
                if includeParts {
                    setInventoryPart = partsResult
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
