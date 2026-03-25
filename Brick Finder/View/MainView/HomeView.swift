//
//  HomeView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/12/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var searchText = ""
    @State private var showingAddItem = false
    @State private var selectedThemeId: String?
    @State var setSavedDataVM: SavedLegoSetsVM
    @State var minifigureSavedDataVM: SavedMinifiguresVM
    @State var partSavedDataVM: SavedLegoPartVM
    
    @StateObject private var minifigsViewModel = MinifiguresVM()
    @StateObject private var setViewModel = SetVM()
    @StateObject private var partViewModel = PartVM()
    @StateObject private var themeViewModel = ThemeViewModel()
    
    //    @Query(sort: \ViewedItem.timestamp, order: .reverse)
    //    var history: ViewedItem
    
    init(context: ModelContext) {
        self.setSavedDataVM = SavedLegoSetsVM(context: context)
        self.minifigureSavedDataVM = SavedMinifiguresVM(context: context)
        self.partSavedDataVM = SavedLegoPartVM(context: context)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header & Search
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // MARK: - Category Pills (Mockup)
                        categoryPills
                        
                        // MARK: - Hero/Featured Section (Mockup)
                        featuredSetHero
                        
                        // MARK: - Your Collection Grid (The 4 Views)
                        Text("My Collection")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            // 1. Saved Minifigures
                            NavigationLink(destination: SavedMinifiguresScreen(viewModel: minifigureSavedDataVM)) {
                                CollectionCard(title: "Saved Minifigs", image: "person.3.fill", color: .blue)
                            }
                            
                            // 2. Saved Sets
                            NavigationLink(destination: SavedLegoSetsScreen(viewModel: setSavedDataVM)) {
                                CollectionCard(title: "Saved Sets", image: "box.truck.fill", color: .orange)
                            }
                            
                            // 3. Saved Parts
                            NavigationLink(destination: SavedLegoPartScreen(viewModel: partSavedDataVM)) {
                                CollectionCard(title: "Saved Parts", image: "puzzlepiece.fill", color: .green)
                            }
                            
                            // 4. LEGO Instructions (Logic Placeholder)
                            NavigationLink(destination: Text("Instructions View Coming Soon")) {
                                CollectionCard(title: "Instructions", image: "doc.text.fill", color: .purple)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top)
                }
            }
            .background(Color(uiColor: .secondarySystemBackground))
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                HStack {
                    Text("Brick Finder")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.red)
                }
                
                Button(action: {}) {
                    Image(systemName: "slider.horizontal.3")
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 10)
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    
    private var categoryPills: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if themeViewModel.isLoading {
                        ProgressView()
                            .padding(.leading, 4)
                    } else if let themes = themeViewModel.legoThemes, !themes.isEmpty {
                        ForEach(themes) { legoTheme in
                            Button {
                                guard selectedThemeId != legoTheme.id else { return }
                                selectedThemeId = legoTheme.id
                                setViewModel.getLegoSetWithTeme(themeId: legoTheme.id)
                            } label: {
                                CategoryPill(
                                    theme: legoTheme,
                                    isSelected: legoTheme.id == (selectedThemeId ?? themes.first?.id)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        Text(themeViewModel.errorMessage ?? "No themes loaded yet.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
            }
            if let err = themeViewModel.errorMessage, !err.isEmpty {
                Text(err)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
        }
        .task {
            themeViewModel.getAllLegoThemes()
            
        }
        .onChange(of: themeViewModel.legoThemes?.first?.id) { _, newValue in
            guard selectedThemeId == nil, let firstThemeId = newValue else { return }
            selectedThemeId = firstThemeId
            setViewModel.getLegoSetWithTeme(themeId: firstThemeId)
        }
    }
    
//    private func listThemeItem(theme: Themes.ThemesResults) -> some View {
//        CategoryPill(theme: theme, isSelected: true)
//    }
    
    private var featuredSetHero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Featured Sets")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    if setViewModel.isLoading {
                        ProgressView()
                            .padding(.horizontal)
                    } else if let sets = setViewModel.legoSet, !sets.isEmpty {
                        ForEach(sets, id: \.setNumber) { set in
                            FeaturedSetCard(setInfo: set)
                                .frame(width: 280)
                                .padding(.vertical, 4)
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .frame(width: 280, height: 240)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "cube.box")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("No sets for this theme")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            )
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
            }
            
        }
    }
}

//#Preview {
//    HomeView()
//}
