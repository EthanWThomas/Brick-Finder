//
//  SetVM.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import Foundation

class SetVM: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    @Published var searchText = ""
    @Published var themeId: String = ""
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

    /// Loads the Set Detail screen dependencies concurrently (Brickable + Rebrickable + inventory).
    /// Call this from the view using `.task(id:)` so it cancels automatically when the set changes.
    func loadSetDetail(setNumber: String, inventoryVM: InventoryPartsVM) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
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
                    await MainActor.run { self.setInfo = info }
                } catch {
                    await MainActor.run { self.errorMessage = error.localizedDescription }
                }
            }
        }

        await MainActor.run { isLoading = false }

        // Phase 2: load MOCs after the details are likely visible.
        Task { [weak self] in
            guard let self else { return }
            if Task.isCancelled { return }
            do {
                let mocs = try await self.apiManager.getAlternateLegoSet(set: setNumber).results
                if Task.isCancelled { return }
                await MainActor.run { self.legoSetMOCS = mocs }
            } catch {
                if Task.isCancelled { return }
                await MainActor.run { self.errorMessage = error.localizedDescription }
            }
        }
    }
     
    var searchLegoSet: [LegoSet.SetResults]? {
        get { return getsearchResult() }
    }
    
    @MainActor
    func seacrhLegoSet() {
        isLoading = true
        
        Task { [weak self] in
            do {
                guard let searchText = self?.searchText
                else { return }
                
                let results = try await self?.apiManager.seacrhAllLegoSets(with: searchText).results
                self?.isLoading = false
                
                await MainActor.run { [weak self] in
                    self?.legoSetResults = results!
                }
            } catch {
                print("No Result Found \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }
    
    /// Loads instructions for a set number (e.g. from search). Trims whitespace; empty input clears results.
    @MainActor
    func getLegoIntructions(with setNumber: String) {
        let query = setNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            isLoading = false
            errorMessage = nil
            instructions = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.brickableApiManager.getInstructions(with: query).instructions
                await MainActor.run {
                    self.instructions = result
                    self.isLoading = false
                }
            } catch {
                print("Instructions load failed: \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    @MainActor
    func searchLegoSetWithTheme() {
        isLoading = true
        
        Task { [weak self] in
            do {
                guard let searchText = self?.searchText
                else { return }
                
                guard let themeId = self?.themeId
                else { return }
                
                let results = try await self?.apiManager.searchLegoSetWithTheme(searchTerm: searchText, theme: themeId).results
                self?.isLoading = true
                
                await MainActor.run { [weak self] in
                    self?.legoSetResults = results!
                }
            } catch {
                print("No Result Found \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }
    
    
    @MainActor
    func searchLegoSetWithAThemeAndYear() {
        Task { [weak self] in
            do {
                guard let searchText = self?.searchText
                else { return }
                
                guard let themeId = self?.themeId
                else { return }
                
                guard let minYear = self?.minYear
                else { return }
                
                guard let maxYear = self?.maxYear
                else { return }
                
                let results = try await self?.apiManager.searchLegoSetWithThemeAndYear(
                    searchTerm: searchText,
                    theme: themeId,
                    minYear: Double(minYear),
                    maxYear: Double(maxYear)
                ).results
                self?.isLoading = true
                
                await MainActor.run { [weak self] in
                    self?.legoSetResults = results!
                }
            } catch {
                print("No Result Found \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }
    
    @MainActor
    func getLegoSet() {
        isLoading = true
        Task {
            do {
                self.legoSet = try await apiManager.getAllLegoSet().results
                isLoading = false
            } catch {
                print(error)
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getSetInfo(with params: String) {
        isLoading = true
        Task {
            do {
                self.setInfo = try await brickableApiManager.getSet(setNumber: params).sets
                isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
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
        Task {
            do {
                self.legoSetMOCS = try await apiManager.getAlternateLegoSet(set: setNumber).results
                isLoading = false
            } catch {
                print(error)
                self.errorMessage =  error.localizedDescription
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
