//
//  HomeView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/12/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @State private var showingAddItem = false
    @State var setSavedDataVM: SavedLegoSetsVM
    @State var minifigureSavedDataVM: SavedMinifiguresVM
    
    @StateObject private var minifigsViewModel = MinifiguresVM()
    @StateObject private var setViewModel = SetVM()
    @StateObject private var partViewModel = PartVM()
    
    init(context: ModelContext) {
        self.setSavedDataVM = SavedLegoSetsVM(context: context)
        self.minifigureSavedDataVM = SavedMinifiguresVM(context: context)
    }
     
     let recentItems = [
         RecentItem(id: 1, title: "Castle Set 31120", subtitle: "Creator Series", icon: "🏰"),
         RecentItem(id: 2, title: "Red Brick 2x4", subtitle: "Basic Parts", icon: "🚗")
     ]
    
    var body: some View {
           NavigationStack {
               ZStack {
                   Color(.systemGroupedBackground)
                       .ignoresSafeArea()
                   
                   ScrollView {
                       VStack(spacing: 24) {
                           // Header Section
                           VStack(alignment: .leading, spacing: 16) {
                               HStack {
                                   Text("🧱 Brick Finder")
                                       .font(.largeTitle)
                                       .fontWeight(.heavy)
                                       .foregroundColor(.legoRed)
                                   Spacer()
                               }
                               
//                               SearchBar(searchText: $searchText)
                           }
                           .padding(.horizontal)
                           
                           // Categories Section
                           VStack(alignment: .leading, spacing: 16) {
                               HStack {
                                   Text("Save Collection")
                                       .font(.title2)
                                       .fontWeight(.bold)
                                   Spacer()
                               }
                               .padding(.horizontal)
                               
                               LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                                   NavigationLink {
                                       SavedMinifiguresScreen(viewModel: minifigureSavedDataVM)
                                   } label: {
                                       MinifigureSavedDataView()
                                   }
                                   NavigationLink {
                                       SavedLegoSetsScreen(viewModel: setSavedDataVM)
                                   } label: {
                                       SetSavedDataView()
                                   }
                                   PartSavedDataView()
                               }
                               .padding(.horizontal)
                           }
                           
                           // Recent Section
                           VStack(alignment: .leading, spacing: 16) {
                               HStack {
                                   Text("Recently Viewed")
                                       .font(.title2)
                                       .fontWeight(.bold)
                                   Spacer()
                               }
                               .padding(.horizontal)
                               
                               LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                                   ForEach(recentItems) { item in
                                       RecentItemCardView(item: item)
                                   }
                               }
                               .padding(.horizontal)
                           }
                           
                           Spacer(minLength: 100)
                       }
                       .padding(.top)
                   }
                   
                   // Floating Action Button
                   VStack {
                       Spacer()
                       HStack {
                           Spacer()
                           Button(action: {
                               showingAddItem = true
                           }) {
                               Image(systemName: "plus")
                                   .font(.title2)
                                   .fontWeight(.semibold)
                                   .foregroundColor(.white)
                                   .frame(width: 56, height: 56)
                                   .background(Color.legoRed)
                                   .clipShape(Circle())
                                   .shadow(color: .legoRed.opacity(0.3), radius: 8, x: 0, y: 4)
                           }
                           .padding(.trailing, 20)
                           .padding(.bottom, 100)
                       }
                   }
               }
               .navigationBarHidden(true)
           }
           .sheet(isPresented: $showingAddItem) {
               AddItemView()
           }
       }
}

//#Preview {
//    HomeView()
//}
