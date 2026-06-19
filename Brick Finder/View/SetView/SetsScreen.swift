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
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
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
                // Picking a theme reloads immediately (this also resets the year
                // range via the VM's `themeId` didSet).
                .onChange(of: viewModel.themeId) { _, _ in
                    viewModel.searchLegoSetWithTheme()
                }
                // "Year From" fires a fresh load on its own — the VM defaults the
                // missing "To" side to the current year so results appear right away.
                .onChange(of: viewModel.minYear) { _, _ in
                    guard viewModel.minYear != 0 || viewModel.maxYear != 0 else { return }
                    viewModel.searchLegoSetWithAThemeAndYear()
                }
                // "Year To" likewise fires independently; the VM defaults the
                // missing "From" side to the earliest LEGO year.
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
//            ThemePickerMenu(themeId: $viewModel.themeId, themeViewModel: themeViewModel)
            ThemeButton(themeId: $viewModel.themeId, themeViewModel: themeViewModel)
            Spacer()
        }
    }
    
    private var minAndMaxYearPicker: some View {
        HStack {
            Menu("Year From") {
                Picker("Minimum", selection: $viewModel.minYear) {
                    ForEach(1999...2028, id: \.self) { year in
                        Text(year.formatted(.number.grouping(.never)))
                    }
                }
            }
            // Size to the label so "Year From"/"Year To" is never truncated,
            // then pin only the height for a consistent control size.
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(height: 40)
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
            
            Menu("Year To") {
                Picker("Maximum", selection: $viewModel.maxYear) {
                    ForEach(1999...2028, id: \.self) { year in
                        Text(year.formatted(.number.grouping(.never)))
                    }
                }
            }
            // Size to the label so "Year From"/"Year To" is never truncated,
            // then pin only the height for a consistent control size.
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(height: 40)
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
                            // Infinite scroll: as each row appears, ask the VM
                            // whether we're close enough to the bottom to fetch
                            // the next page. New sets append seamlessly.
                            .onAppear {
                                viewModel.loadMoreSetsIfNeeded(currentItem: set)
                            }
                    }

                    // Spinner pinned below the list while the next page loads.
                    if viewModel.isLoadingMoreSets {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
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
            .adaptiveReadableWidth(AdaptiveLayout.ContentWidth.standard, sizeClass: horizontalSizeClass)
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
