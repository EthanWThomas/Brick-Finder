//
//  PartVM.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import Foundation

class PartVM: ObservableObject {
    
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?
    
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
    
    var searchLegoPart: [AllParts.PartResults]? {
        get { return getsearchResult() }
    }
    
    @MainActor
    func searchLegoParts() {
        isLoading = true
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await self.apiManager.searchParts(with: self.searchText).results
                await MainActor.run {
                    self.isLoading = false
                    self.legoPartsResult = results
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
    
    @MainActor
    func searchLegoPartWithAPartId() {
        isLoading = true
        
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
        Task {
            do {
                self.part = try await apiManager.getPart().results
                isLoading = false
            } catch {
                print(error)
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getminifigePart(figNumber: String) {
        isLoading = true
        
        Task {
            do {
                self.inventoryPart = try await apiManager.getMinifigerInvetory(setNum: figNumber).results
                self.isLoading = false
            } catch {
                print(error)
                errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getLegoPartsColor(part number: String) {
        isLoading = true
        
        Task {
            do {
                self.partColor = try await apiManager.getListOfPartColor(part: number).results
                self.isLoading = false
            } catch {
                print(error)
                errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getDetailAboutSpecificPart(partNumber: String) {
        isLoading = true
        Task {
            do {
                self.legoPart = try await apiManager.getDetailAboutPart(part: partNumber)
                self.isLoading = false
            } catch {
                print(error)
                errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getDetailsAboutPartAndColorCombination(partNumber: String, colorId: String) {
        isLoading = true
        
        Task {
            do {
                self.colors = try await apiManager.getListOfPartCombinations(part: partNumber, color: colorId)
                self.isLoading = false
            } catch {
                print(error)
                errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getListOfAllSetsPartAndColorCombination(partNumber: String, colorId: String) {
        isLoading = true
        
        Task {
            do {
                self.legoSet = try await apiManager.getallSetThePartAndColorCombinationItHasApperadIn(part: partNumber, color: colorId).results
                self.isLoading = false
            } catch {
                print(error)
                errorMessage = error.localizedDescription
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
