//
//  SavedLegoSetsVM.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 10/22/25.
//


import Foundation
import SwiftData
import Observation

@MainActor
@Observable
class SavedLegoSetsVM {
    let context: ModelContext
    
    var legoDataModel = [LegoSetsDataModel]()
    
    init (context: ModelContext) {
        self.context = context
        
    }
    
    func fetchLocalResults() {
        do {
            self.legoDataModel = try context.fetch(FetchDescriptor<LegoSetsDataModel>())
        } catch {
            print("Error Fetching Local Result \(error)")
        }
    }
    
    func savedLegoSetsResult(legoResult: LegoSet.SetResults) {
        let resultModel = LegoSetsDataModel(
            setNumber: legoResult.setNumber,
            name: legoResult.name,
            year: legoResult.year,
            themeID: legoResult.themeID,
            numberOfParts: legoResult.numberOfParts,
            setImageURL: legoResult.setImageURL,
            setURL: legoResult.setURL,
            lastModifieDT: legoResult.lastModifieDT)
        context.insert(resultModel)
        try? context.save()
        fetchLocalResults()
    }
    
    func deleteLegoResult(lego set: LegoSetsDataModel) {
        context.delete(set)
        try? context.save()
        fetchLocalResults()
    }
}
