//
//  PartsView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI
import SwiftData


struct PartsScreen: View {
    @EnvironmentObject private var partCategoryViewModel: PartCategoryViewModel
    @StateObject var viewModel = PartVM()
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showDropdown = false
    @State var savedPartViewModel: SavedLegoPartVM
    
    init(context: ModelContext) {
        self.savedPartViewModel = SavedLegoPartVM(context: context)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                header
                
                HStack {
                    HStack {
                        PartCategoryPickerMenu(
                            partCategoryId: $viewModel.partId,
                            partCategoryViewModel: partCategoryViewModel
                        )
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                partCard
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
        .task {
            partCategoryViewModel.loadCategoriesIfNeeded()
        }
        .onChange(of: viewModel.partId) { _, _ in
            viewModel.searchLegoPartWithAPartId()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Lego Parts")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color("TabbarColor"))
                Spacer()
            }
            SearchBar(searchText: $viewModel.searchText, onSubmit: { viewModel.submitSearch() })
        }
        .padding(.horizontal)
    }
    
    private var partCard: some View {
        ScrollView {
            let trimmedSearch = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let hasNoQuery = trimmedSearch.isEmpty && viewModel.partId.isEmpty
            // Treat the cache as "has data" when we have any parts to show. We
            // never want to replace a populated list with the error UI just
            // because a stale/transient error is hanging around on the VM.
            let hasCachedDefaults = !(viewModel.part?.isEmpty ?? true)
            let hasCachedSearch = !(viewModel.searchLegoPart?.isEmpty ?? true)
            let hasAnyData = hasCachedDefaults || hasCachedSearch

            // Only show the full-screen spinner when there's nothing cached
            // to display. If we already have a populated grid (e.g. when
            // returning from the part detail screen, or when filters refresh
            // in the background), keep the LazyVGrid mounted so SwiftUI can
            // preserve the ScrollView's offset across navigation.
            if viewModel.isLoading && !hasAnyData {
                ProgressView("Loading parts…")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else if let errorMessage = viewModel.errorMessage, !hasAnyData {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Couldn’t load parts")
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
                if let defaultParts = viewModel.part, !defaultParts.isEmpty {
                    partsGrid(parts: defaultParts)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Search for a part")
                            .font(.headline)
                        Text("Enter a part name or pick a category to begin.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
            } else if let parts = viewModel.searchLegoPart, !parts.isEmpty {
                partsGrid(parts: parts)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "questionmark.folder")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Part not found.")
                        .font(.headline)
                    Text("Try a different name or category.")
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
            // part detail view) before we kick off a fresh load.
            viewModel.clearListError()
            // Only fetch the default parts if we don't already have them cached;
            // otherwise we'd flash a loading spinner every time the user returns
            // from the detail screen.
            if viewModel.part == nil {
                viewModel.getPart()
            }
        }
        .zIndex(showDropdown ? 1 : 100)
    }

    private func partsGrid(parts: [AllParts.PartResults]) -> some View {
        LazyVGrid(columns: AdaptiveLayout.cardColumns(spacing: 24), spacing: 24) {
            ForEach(parts, id: \.partNumber) { part in
                listPartItem(lego: part)
            }
        }
        .padding(.horizontal)
        .adaptiveReadableWidth(AdaptiveLayout.ContentWidth.wide, sizeClass: horizontalSizeClass)
    }
    
    private func listPartItem(lego part: AllParts.PartResults) -> some View {
        NavigationLink {
            PartDetailsView(
                viewModel: viewModel,
                legoPart: part)
        } label: {
            PartCard(part: part, viewModel: savedPartViewModel)
        }
    }
}

