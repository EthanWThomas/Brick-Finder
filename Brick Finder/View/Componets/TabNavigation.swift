//
//  TabNavigation.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI

struct TabNavigation: View {
    @State private var selectedTab = 0
    @State private var searchText: String = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(searchText: $searchText)
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)
            
            MinifiguresScreen()
                .tabItem { Label("Minifigures", systemImage: "person.crop.circle") }
                .tag(1)
            
            PartsScreen()
                .tabItem { Label("Parts", systemImage: "square.and.arrow.down") }
                .tag(2)
            
            SetsScreen()
                .tabItem { Label("Sets", systemImage: "folder.fill") }
                .tag(3)
        }
    }
}

#Preview {
    TabNavigation()
}
