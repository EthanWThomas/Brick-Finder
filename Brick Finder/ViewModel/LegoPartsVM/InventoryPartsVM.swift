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
            do {
                guard let inventoryPart = self?.setNumber
                else { return }
                
                let results = try await self?.apiManager.getInvetoryPartInASet(setNum: inventoryPart).results
                self?.isLoading = false
                
                await MainActor.run { [weak self] in
                    self?.inventoryPartResults = results!
                }
            } catch {
                print("No Result Found \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }
    
    @MainActor
    func getInventoryPart(with setNumber: String) {
        Task { @MainActor in
            await loadSetInventory(setNumber: setNumber, includeMinifigs: false)
        }
    }
    
    @MainActor
    func getInventoryMinifigerInSet(with setNumber: String) {
        Task { @MainActor in
            await loadSetInventory(setNumber: setNumber, includeParts: false)
        }
    }

    /// Loads inventory parts + minifigs concurrently for a set.
    /// Use this from a parent loader (e.g. `SetVM`) to avoid multiple overlapping Tasks.
    @MainActor
    func loadSetInventory(setNumber: String, includeParts: Bool = true, includeMinifigs: Bool = true) async {
        isLoading = true
        errorMessage = nil

        do {
            async let partsTask: [InventoryParts.PartResult]? = includeParts
            ? apiManager.getInvetoryPartInASet(setNum: setNumber).results
            : nil

            async let minifigsTask: [Lego.LegoResults]? = includeMinifigs
            ? apiManager.getInvetoryMinifigerInASet(with: setNumber).results
            : nil

            if includeParts {
                setInventoryPart = try await partsTask
            }
            if includeMinifigs {
                getInventoryMinifiger = try await minifigsTask
            }

            isLoading = false
        } catch {
            print(error)
            errorMessage = error.localizedDescription
            isLoading = false
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
