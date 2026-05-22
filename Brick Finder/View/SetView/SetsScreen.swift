//
//  SetsView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI
import SwiftData

struct SetsScreen: View {
    @EnvironmentObject private var themeViewModel: ThemeViewModel
    @StateObject var viewModel = SetVM()
    @StateObject var inventoryVM = InventoryPartsVM()
    
    @State var setSavedDataVM: SavedLegoSetsVM
    
    @State private var isSearching = false
    @State private var showDropdown = false
    
    init(context: ModelContext) {
        self.setSavedDataVM = SavedLegoSetsVM(context: context)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 24) {
                    // Header
                    header
                        .padding(.horizontal)
                    HStack(spacing: 12) {
                        HStack {
                            themePicker
                            minAndMaxYearPicker
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Filters
                    listSetview
                        .padding(.horizontal, -15)
                }
                .onChange(of: viewModel.themeId) { _, _ in
                    viewModel.searchLegoSetWithTheme()
                }
                .onChange(of: viewModel.minYear) { _, _ in
                    guard viewModel.minYear != 0 || viewModel.maxYear != 0 else { return }
                    viewModel.searchLegoSetWithAThemeAndYear()
                }
                .onChange(of: viewModel.maxYear) { _, _ in
                    guard viewModel.minYear != 0 || viewModel.maxYear != 0 else { return }
                    viewModel.searchLegoSetWithAThemeAndYear()
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
        .task {
            themeViewModel.loadThemesIfNeeded()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Lego Set")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color("TabbarColor"))
                Spacer()
            }
            SearchBar(searchText: $viewModel.searchText, onSubmit: { viewModel.submitSearch() })
        }
    }
    
    private var themePicker: some View {
        HStack {
            ThemePickerMenu(themeId: $viewModel.themeId, themeViewModel: themeViewModel)
            Spacer()
        }
    }
    
    private var minAndMaxYearPicker: some View {
        HStack {
            Menu("Min_year") {
                Picker("Minimum", selection: $viewModel.minYear) {
                    ForEach(1999...2055, id: \.self) { year in
                        Text(year.formatted(.number))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(width: 100, height: 40)
            .foregroundStyle(Color.black)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(Color.gray)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .cornerRadius(8)
            .offset(y: 4)
            .zIndex(1000)
            Spacer()
            
            Menu("Max_year") {
                Picker("Maximum", selection: $viewModel.maxYear) {
                    ForEach(1999...2055, id: \.self) { year in
                        Text(year.formatted(.number))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(width: 100, height: 40)
            .foregroundStyle(Color.black)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(Color.gray)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .cornerRadius(8)
            .offset(y: 4)
            .zIndex(1000)
            Spacer()
        }
    }
    
    private var listSetview: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                let trimmedSearch = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                let hasNoQuery = trimmedSearch.isEmpty && viewModel.themeId.isEmpty
                // Treat the cache as "has data" when we have any sets to show. We
                // never want to replace a populated list with the error UI just
                // because a stale/transient error is hanging around on the VM.
                let hasCachedDefaults = !(viewModel.legoSet?.isEmpty ?? true)
                let hasCachedSearch = !(viewModel.searchLegoSet?.isEmpty ?? true)
                let hasAnyData = hasCachedDefaults || hasCachedSearch

                // Only show the full-screen spinner when there's nothing cached
                // to display. If we already have a populated list (e.g. when
                // returning from the detail screen, or when filters refresh in
                // the background), keep the LazyVStack mounted so SwiftUI can
                // preserve the ScrollView's offset across navigation.
                if viewModel.isLoading && !hasAnyData {
                    ProgressView("Loading sets…")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let errorMessage = viewModel.errorMessage, !hasAnyData {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Couldn’t load sets")
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
                    if let defaultSets = viewModel.legoSet, !defaultSets.isEmpty {
                        ForEach(defaultSets, id: \.setNumber) { set in
                            listSetItem(lego: set)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "text.magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Search for a set")
                                .font(.headline)
                            Text("Enter a set name or pick a theme to begin.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    }
                } else if let legoSet = viewModel.searchLegoSet, !legoSet.isEmpty {
                    ForEach(legoSet, id: \.setNumber) { set in
                        listSetItem(lego: set)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.folder")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Set not found.")
                            .font(.headline)
                        Text("Try a different name, theme, or year range.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
            }
            .padding()
        }
        .onAppear {
            // Clear any stale list-level error left over from previous activity
            // (e.g. a request that was cancelled when navigating back from the
            // detail view) before we kick off a fresh load.
            viewModel.clearListError()
            // Only fetch the default sets if we don't already have them cached;
            // otherwise we'd flash a loading spinner every time the user returns
            // from the detail screen.
            if viewModel.legoSet == nil {
                viewModel.getLegoSet()
            }
        }
    }
    
    private func listSetItem(lego set: LegoSet.SetResults) -> some View {
        NavigationLink {
            SetDetailView(
                legoSet: set,
                viewModel: viewModel,
                inventoryVM: inventoryVM)
        } label: {
            SetsCardView(legoSet: set, setSavedDataVM: setSavedDataVM)
        }
    }
}

//#Preview {
//    SetsScreen()
//}
