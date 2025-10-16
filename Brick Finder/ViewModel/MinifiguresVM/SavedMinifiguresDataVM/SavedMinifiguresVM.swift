//
//  SavedMinifiguresVM.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 10/16/25.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
class SavedMinifiguresVM {
    
    let context: ModelContext
    
    var legoDataModel = [LegoDataModel]()
    
    init (context: ModelContext) {
        self.context = context
        
        fetchLocalResult()
    }
    
    func fetchLocalResult() {
        do {
            self.legoDataModel = try context.fetch(FetchDescriptor<LegoDataModel>())
        } catch {
            print("Error Fetching Local Result \(error)")
        }
    }
    
    func savedLegoResult(legoResult: Lego.LegoResults) {
        let resultModel = LegoDataModel(
            setNum: legoResult.setNum,
            name: legoResult.name,
            numberOfParts: legoResult.numberOfPart,
            setImageUrl: legoResult.setImageURL,
            setUrl: legoResult.setURL,
            lastModifledDT: legoResult.lastModifledDT)
        context.insert(resultModel)
        try? context.save()
        fetchLocalResult()
    }
    
    func deleteLegoResult(legoDataModel: LegoDataModel) {
        context.delete(legoDataModel)
        try? context.save()
        fetchLocalResult()
    }
}
