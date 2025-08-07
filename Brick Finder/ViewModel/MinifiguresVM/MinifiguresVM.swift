//
//  Minifigures.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import Foundation

class MinifiguresVM: ObservableObject {
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?
    
    @Published var seacrhText = ""
    @Published var themeId = ""
    
    @Published var minifiguresResult = [Lego.LegoResults]()
    @Published var miniFigures: [Lego.LegoResults]?
    
    private let apiManager = RebrickableApi()
    
    var searchMinifigures: [Lego.LegoResults]? {
        get { return getSeacrhResult() }
    }
    
    @MainActor
    func seacrhMinifigures() {
        isLoading = true
        
        Task { [weak self] in
            do {
                guard let searchText = self?.seacrhText else { return }
                
                let results = try await self?.apiManager.searchMinfigs(with: searchText).results
                self?.isLoading = false
                
                await MainActor.run { [weak self] in
                    self?.minifiguresResult = results!
                }
            } catch {
                print("No Result Found \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }
    
    @MainActor
    func seacrhMinifiguresWithAThemeId() {
        isLoading = true
        
        Task { [weak self] in
            do {
                guard let searchText = self?.seacrhText else { return }
                guard let themeId = self?.themeId else { return }
                
                let results = try await self?.apiManager.searchMinifigureWithThemeId(theme: searchText, with: themeId).results
                self?.isLoading = false
                
                await MainActor.run { [weak self] in
                    self?.minifiguresResult = results!
                }
            } catch {
                print("No Result Found \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }
    
    @MainActor
    func getMiniFigures() {
        isLoading = true
        
        Task {
            do {
                
                self.miniFigures = try await apiManager.getMinifig().results
                self.isLoading = false
            } catch {
                print(error)
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func getMinifiguresThemeId(themeId: String) {
        isLoading = true
        
        Task {
            do {
                self.miniFigures = try await apiManager.getMinifigureWithATheme(theme: themeId).results
                self.isLoading = false
            } catch {
                print("No Result Found \(error)")
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
//    @MainActor
//    func clearSearch() {
//        seacrhText = ""
//        minifiguresResult = []
//    }
    
    func getSeacrhResult() -> [Lego.LegoResults]? {
        if seacrhText.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return minifiguresResult
        } else {
            return minifiguresResult.filter { result in
                result.name?.range(of: seacrhText, options: .caseInsensitive) != nil
            }
        }
    }
}
