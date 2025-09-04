//
//  SetVM.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import Foundation

class SetVM: ObservableObject {
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?
    
    @Published var searchText = ""
    @Published var themeId: String? = ""
    @Published var maxYear = 0
    @Published var minYear = 0
    
    @Published var legoSetResults = [LegoSet.SetResults]()
    @Published var legoTheme = LegoThemes.allCases.map { $0.rawValue }
    @Published var legoSet: [LegoSet.SetResults]?
    @Published var legoSetMOCS: [LegoMOCS.LegoMOCSResult]?
    
    private let apiManager = RebrickableApi()
    
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
    func getLegoSetWithTeme(themeId: String) {
        Task {
            do {
                self.legoSet = try await apiManager.getSetWithThemeId(themeId: themeId).results
                self.isLoading = false
            } catch {
                print(error)
                self.errorMessage = error.localizedDescription
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
