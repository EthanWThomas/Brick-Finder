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
    func seacrhMinifigures() {
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await self.apiManager.searchMinfigs(with: self.seacrhText).results
                await MainActor.run {
                    self.isLoading = false
                    self.minifiguresResult = results
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
    func seacrhMinifiguresWithAThemeId() {
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await self.apiManager.searchMinifigureWithThemeId(
                    theme: self.themeId,
                    with: self.seacrhText
                ).results
                await MainActor.run {
                    self.isLoading = false
                    self.minifiguresResult = results
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
        if seacrhText.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return minifiguresResult
        } else {
            return minifiguresResult.filter { result in
                result.name?.range(of: seacrhText, options: .caseInsensitive) != nil
            }
        }
    }
}
