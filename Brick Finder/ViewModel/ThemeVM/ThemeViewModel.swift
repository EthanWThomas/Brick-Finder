//
//  ThemeViewModel.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 3/17/26.
//

import Foundation

class ThemeViewModel: ObservableObject {
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?
    
    @Published var legoThemes: [Themes.ThemesResults]?
    
    private let rebrickable = RebrickableApi()
    
    @MainActor
    func getAllLegoThemes() {
        isLoading = true
        errorMessage = nil
        // Updates to @Published must happen on the main actor (Task     {} alone can run off-main).
        Task { @MainActor in
            do {
                self.legoThemes = try await rebrickable.getAllLegoTheme().themes
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.legoThemes = nil
                self.isLoading = false
            }
        }
    }
}
