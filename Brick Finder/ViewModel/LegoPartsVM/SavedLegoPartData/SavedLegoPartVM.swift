//
//  SavedLegoPartVM.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 1/12/26.
//

import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
class SavedLegoPartVM {
    let context: ModelContext
    
    var legoDataModel = [LegoPartsDataModel]()
    
    init(context: ModelContext) {
        self.context = context
        
        fechLocalResult()
    }
    
    func fechLocalResult () {
        do {
            self.legoDataModel = try context.fetch(FetchDescriptor<LegoPartsDataModel>())
        } catch {
            print("Error Fetching Local Result \(error)")
        }
    }
    
    func savedLegoPart(partReuslt: AllParts.PartResults) {
        let reusltModel = LegoPartsDataModel(
            partNumber: partReuslt.partNumber,
            name: partReuslt.name,
            partCatId: partReuslt.partCatId,
            partUrl: partReuslt.partUrl,
            partImageUrl: partReuslt.partImageUrl)
        context.insert(reusltModel)
        try? context.save()
        fechLocalResult()
    }
    
    func deleteSavedPart(part: LegoPartsDataModel) {
        context.delete(part)
        try? context.save()
        fechLocalResult()
    }
}
