//
//  HomeView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/12/25.
//

import SwiftUI
import SwiftData
/// Remote photos use stable Wikimedia Commons URLs (CC-licensed), not Google Image hotlinks.
private enum HomeCollectionPhotos {
    static let minifigs = URL(string: "https://upload.wikimedia.org/wikipedia/commons/3/3d/LEGO_minifigures_display_case.jpg")!
    /// Vintage set photo including box (Wikimedia Commons).
    static let setWithBox = URL(string: "https://upload.wikimedia.org/wikipedia/commons/0/0d/Lego_Space_-_Set_6823_Surface_Transport_%287465208532%29.jpg")!
    static let parts = URL(string: "https://upload.wikimedia.org/wikipedia/commons/3/32/Lego_Color_Bricks.jpg")!
    static let instructions = URL(string: "https://upload.wikimedia.org/wikipedia/commons/7/7e/Lego_instructions.jpg")!
}

struct HomeView: View {
    @State private var searchText = ""
    @State private var showingAddItem = false
    @State private var selectedThemeId: String?
    @State private var showAllThemes = false
    @State var setSavedDataVM: SavedLegoSetsVM
    @State var minifigureSavedDataVM: SavedMinifiguresVM
    @State var partSavedDataVM: SavedLegoPartVM
    
    @StateObject private var minifigsViewModel = MinifiguresVM()
    @StateObject private var inventoryViemModel = InventoryPartsVM()
    @StateObject private var setViewModel = SetVM()
    @StateObject private var partViewModel = PartVM()
    @EnvironmentObject private var themeViewModel: ThemeViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
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
                        
                        collectionGrid
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top)
                    .adaptiveReadableWidth(AdaptiveLayout.ContentWidth.wide, sizeClass: horizontalSizeClass)
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    private var collectionGrid: some View {
        LazyVGrid(columns: AdaptiveLayout.cardColumns(), spacing: 16) {
            // 1. Saved Minifigures
            NavigationLink(destination: SavedMinifiguresScreen(viewModel: minifigureSavedDataVM)) {
                CollectionCard(title: "Saved Minifigs", photo: .remote(HomeCollectionPhotos.minifigs), color: .blue)
            }
            
            // 2. Saved Sets
            NavigationLink(destination: SavedLegoSetsScreen(viewModel: setSavedDataVM)) {
                CollectionCard(title: "Saved Sets", photo: .remote(HomeCollectionPhotos.setWithBox), color: .orange)
            }
            
            // 3. Saved Parts
            NavigationLink(destination: SavedLegoPartScreen(viewModel: partSavedDataVM)) {
                CollectionCard(title: "Saved Parts", photo: .remote(HomeCollectionPhotos.parts), color: .green)
            }
            
            // 4. LEGO Instructions (Logic Placeholder)
            NavigationLink(destination: SearchInstructionView()) {
                CollectionCard(title: "Instructions", photo: .remote(HomeCollectionPhotos.instructions), color: .purple)
            }
        }
        .padding(.horizontal)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                HStack {
                    Text("Brick Finder")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color("TabbarColor"))
                }
                NavigationLink {
                    SettingView()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5)
                }
                
                //                Button(action: {}) {
                //                    Image(systemName: "slider.horizontal.3")
                //                        .padding(12)
                //                        .background(Color.white)
                //                        .clipShape(Circle())
                //                        .shadow(color: .black.opacity(0.05), radius: 5)
                //                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 10)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    
    private var categoryPills: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if themeViewModel.isLoading {
                            ProgressView()
                                .padding(.leading, 4)
                        } else if !themeViewModel.themes.isEmpty {
                            ForEach(themeViewModel.sortedThemes) { legoTheme in
                                Button {
                                    guard selectedThemeId != legoTheme.idString else { return }
                                    selectedThemeId = legoTheme.idString
                                    setViewModel.getLegoSetWithTeme(themeId: legoTheme.idString)
                                } label: {
                                    CategoryPill(
                                        theme: legoTheme,
                                        isSelected: legoTheme.idString == (selectedThemeId ?? themeViewModel.sortedThemes.first?.idString)
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

                allThemesButton
                    .padding(.trailing)
            }
            if let err = themeViewModel.errorMessage, !err.isEmpty {
                Text(err)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
        }
        .task {
            themeViewModel.loadThemesIfNeeded()
        }
        .onChange(of: themeViewModel.themes.first?.id) { _, newValue in
            guard selectedThemeId == nil, let firstThemeId = newValue else { return }
            selectedThemeId = String(firstThemeId)
            setViewModel.getLegoSetWithTeme(themeId: String(firstThemeId))
        }
        .sheet(isPresented: $showAllThemes) {
            allThemesSheet
        }
    }

    private var allThemesButton: some View {
        Button {
            showAllThemes = true
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("TabbarColor"))
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .accessibilityLabel("All themes")
    }

    private var allThemesSheet: some View {
        NavigationStack {
            Group {
                if !themeViewModel.sortedThemes.isEmpty {
                    List {
                        ForEach(themeViewModel.sortedThemes) { theme in
                            Button {
                                selectedThemeId = theme.idString
                                setViewModel.getLegoSetWithTeme(themeId: theme.idString)
                                showAllThemes = false
                            } label: {
                                HStack {
                                    Text(theme.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if theme.idString == selectedThemeId {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                } else if themeViewModel.isLoading {
                    ProgressView("Loading themes…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text(themeViewModel.errorMessage ?? "No themes available.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("All Themes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showAllThemes = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
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
                            listFeaturedSetCard(lego: set)
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
    
    private func listFeaturedSetCard(lego set: LegoSet.SetResults) -> some View {
        NavigationLink {
            SetDetailView(
                legoSet: set,
                viewModel: setViewModel,
                inventoryVM: inventoryViemModel)
        } label: {
            FeaturedSetCard(setInfo: set)
        }
    }
}

//#Preview {
//    HomeView()
//}
