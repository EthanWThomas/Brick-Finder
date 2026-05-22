//
//  MinifiguresView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI
import SwiftData

struct MinifiguresScreen: View {
    @EnvironmentObject private var themeViewModel: ThemeViewModel
    @StateObject var minifiguresVM = MinifiguresVM()
    @StateObject var minifigSetVM = MiniFiguresDetailVM()
    @StateObject var minifigPartVM = PartVM()
    
    @State private var showDropdown = false
    
    @State var minifigurSavedDataVM: SavedMinifiguresVM
    
    init(context: ModelContext) {
        self.minifigurSavedDataVM = SavedMinifiguresVM(context: context)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                headerView
                
                tabbar
                
                miniFiguresGrid
                
            }
            .background(Color(UIColor.secondarySystemBackground))
            .onTapGesture {
                if showDropdown {
                    withAnimation {
                        showDropdown = false
                    }
                }
            }
            .onChange(of: minifiguresVM.themeId) { _, _ in
                minifiguresVM.seacrhMinifiguresWithAThemeId()
            }
            .task {
                themeViewModel.loadThemesIfNeeded()
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Lego Minifigures")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color("TabbarColor"))
                Spacer()
            }
            SearchBar(searchText: $minifiguresVM.seacrhText, onSubmit: { minifiguresVM.submitSearch() })
        }
        .padding(.horizontal)
    }
    
    private var tabbar: some View {
        HStack {
            ThemePickerMenu(themeId: $minifiguresVM.themeId, themeViewModel: themeViewModel)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var miniFiguresGrid: some View {
        ScrollView {
            let trimmedSearch = minifiguresVM.seacrhText.trimmingCharacters(in: .whitespacesAndNewlines)
            let hasNoQuery = trimmedSearch.isEmpty && minifiguresVM.themeId.isEmpty
            // Treat the cache as "has data" when we have any minifigures to show.
            // We never want to swap a populated grid out for the loading or error
            // UI: doing so destroys the LazyVGrid and SwiftUI loses the scroll
            // offset when the view re-appears after a back navigation.
            let hasCachedDefaults = !(minifiguresVM.miniFigures?.isEmpty ?? true)
            let hasCachedSearch = !(minifiguresVM.searchMinifigures?.isEmpty ?? true)
            let hasAnyData = hasCachedDefaults || hasCachedSearch

            if minifiguresVM.isLoading && !hasAnyData {
                ProgressView("Loading minifigures")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else if let errorMessage = minifiguresVM.errorMessage, !hasAnyData {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Couldn’t load Minifigures")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else if hasNoQuery {
                if let defaultMinifigures = minifiguresVM.miniFigures, !defaultMinifigures.isEmpty {
                    minifiguresGridContent(minifigures: defaultMinifigures)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Search for a Minifigure")
                            .font(.headline)
                        Text("Enter a minifigure name or pick a theme to begin.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
            } else if let minifigures = minifiguresVM.searchMinifigures, !minifigures.isEmpty {
                minifiguresGridContent(minifigures: minifigures)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "questionmark.folder")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Minifigure not found.")
                        .font(.headline)
                    Text("Try a different name or theme.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            }
        }
        .onAppear {
            // Clear any stale list-level error left over from previous activity
            // (e.g. a request that was cancelled when navigating back from the
            // detail view) before we kick off a fresh load.
            minifiguresVM.clearListError()
            // Only fetch the default minifigures the first time this view
            // appears. Refetching on every back-navigation rebuilds the data
            // array and toggles `isLoading`, which destroys the LazyVGrid and
            // resets the ScrollView to the top.
            if minifiguresVM.miniFigures == nil {
                minifiguresVM.getMiniFigures()
            }
        }
        .zIndex(showDropdown ? 1 : 100)
    }

    private func minifiguresGridContent(minifigures: [Lego.LegoResults]) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(minifigures, id: \.setNum) { legoMinifigures in
                listMinifigItem(lego: legoMinifigures)
            }
        }
        .padding(.horizontal)
    }
    
    private func listMinifigItem(lego minifigures: Lego.LegoResults) -> some View {
        NavigationLink {
            MinifiguresDetailView(
                minifigure: minifigures,
                minifigureInSetTheyCameIn: minifigSetVM,
                partVM: minifigPartVM)
        } label: {
            MinifigureCardView(minifigures: minifigures, minifigureSavedDataVM: minifigurSavedDataVM)
        }
    }
}

