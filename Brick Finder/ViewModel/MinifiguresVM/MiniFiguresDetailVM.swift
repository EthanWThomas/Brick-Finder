//
//  MiniFiguresDetailVM.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import Foundation

class MiniFiguresDetailVM: ObservableObject {
    
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?
    
    @Published var setNumber = ""
    @Published var minifigInSetResult = [Lego.LegoResults]()
    @Published var minifigInSet: [Lego.LegoResults]?
    
    private let apiManager = RebrickableApi()
    
    @MainActor
    func getMinifigInSetCameIn(figNumber: String) {
        isLoading = true
        
        Task {
            do {
                self.minifigInSet = try await apiManager.getAllMinifigsSetCameIn(setNumber: figNumber).results
                self.isLoading = false
            } catch {
                print(error)
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
}
