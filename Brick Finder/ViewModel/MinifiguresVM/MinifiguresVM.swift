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
    private let searchCoordinator = SearchTaskCoordinator()

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
    
    var searchMinifigures: [Lego.LegoResults]? {
        get { return getSeacrhResult() }
    }
    
    @MainActor
    func submitSearch() {
        let query = SearchQueryNormalizer.normalizedForAPI(seacrhText)
        guard !query.isEmpty else { return }
        runFilteredMinifigureSearch()
    }

    @MainActor
    func seacrhMinifigures() {
        submitSearch()
    }

    @MainActor
    func seacrhMinifiguresWithAThemeId() {
        runFilteredMinifigureSearch()
    }

    @MainActor
    private func runFilteredMinifigureSearch() {
        let query = SearchQueryNormalizer.normalizedForAPI(seacrhText)
        let signature = "minifigs|\(query)|\(themeId)"

        searchCoordinator.run(signature: signature) { [weak self] in
            guard let self else { return }
            await self.performFilteredMinifigureSearch(query: query)
        }
    }

    @MainActor
    private func performFilteredMinifigureSearch(query: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let results: [Lego.LegoResults]
            if query.isEmpty {
                guard !themeId.isEmpty else {
                    isLoading = false
                    return
                }
                results = try await apiManager.searchMinifigureWithThemeId(
                    theme: themeId,
                    with: ""
                ).results
            } else {
                results = try await SearchQueryNormalizer.searchWithFallback(query: query) { term in
                    try await self.fetchMinifigures(searchTerm: term)
                }
            }
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            minifiguresResult = results
            isLoading = false
        } catch {
            if Self.isCancellation(error) {
                isLoading = false
                return
            }
            print("No Result Found \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func fetchMinifigures(searchTerm: String) async throws -> [Lego.LegoResults] {
        if !themeId.isEmpty {
            return try await apiManager.searchMinifigureWithThemeId(
                theme: themeId,
                with: searchTerm
            ).results
        }
        return try await apiManager.searchMinfigs(with: searchTerm).results
    }
    
    @MainActor
    func getMiniFigures() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                
                self.miniFigures = try await apiManager.getMinifig().results
                self.isLoading = false
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
    func getMinifiguresThemeId(themeId: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                self.miniFigures = try await apiManager.getMinifigureWithATheme(theme: themeId).results
                self.isLoading = false
            } catch {
                if Self.isCancellation(error) {
                    self.isLoading = false
                    return
                }
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
        minifiguresResult
    }
}
