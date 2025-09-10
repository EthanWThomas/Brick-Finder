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
        isLoading = true
        
        Task {
            do {
                self.setInventoryPart = try await apiManager.getInvetoryPartInASet(setNum: setNumber).results
                self.isLoading = false
            } catch {
                print(error)
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getInventoryMinifigerInSet(with setNumber: String) {
        isLoading = true
        
        Task {
            do {
                self.getInventoryMinifiger = try await apiManager.getInvetoryMinifigerInASet(with: setNumber).results
                self.isLoading = false
            } catch {
                print(error)
                self.errorMessage = error.localizedDescription
                self.isLoading = false
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
