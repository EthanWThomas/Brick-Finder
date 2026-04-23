//
//  TabNavigation.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI
import SwiftData

struct TabNavigation: View {
    @State private var selectedTab = 0
    @State private var searchText: String = ""
    
    let cantainer: ModelContainer
    
    init() {
        do {
            self.cantainer = try ModelContainer(for: LegoSetsDataModel.self, LegoDataModel.self, LegoPartsDataModel.self)
        } catch {
            NSLog("SwiftData ModelContainer failed: \(error.localizedDescription). Falling back to in-memory store.")
            do {
                let memory = ModelConfiguration(isStoredInMemoryOnly: true)
                self.cantainer = try ModelContainer(
                    for: LegoSetsDataModel.self, LegoDataModel.self, LegoPartsDataModel.self,
                    configurations: memory
                )
            } catch {
                fatalError("Could not load SwiftData container: \(error)")
            }
        }
    }
  
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(context: ModelContext(cantainer))
                .modelContainer(cantainer)
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)
            
            MinifiguresScreen(context: ModelContext(cantainer))
                .modelContainer(cantainer)
                .tabItem { Label("Minifigures", systemImage: "person.crop.circle") }
                .tag(1)
            
            SetsScreen(context: ModelContext(cantainer))
                .modelContainer(cantainer)
                .tabItem { Label("Sets", systemImage: "folder.fill") }
                .tag(2)
            
            PartsScreen(context: ModelContext(cantainer))
                .modelContainer(cantainer)
                .tabItem { Label("Parts", systemImage: "square.and.arrow.down") }
                .tag(3)
        }
        .background(Color("TabbarColor"))
    }
}

#Preview {
    TabNavigation()
}
