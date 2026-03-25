//
//  PartsView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI
import SwiftData


struct PartsScreen: View {
    @StateObject var viewModel = PartVM()
    
    @State private var showDropdown = false
    @State var savedPartViewModel: SavedLegoPartVM

    @StateObject private var partCategoriesVM = PartCategoryViewModel()
    
    init(context: ModelContext) {
        self.savedPartViewModel = SavedLegoPartVM(context: context)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                header
                
                HStack {
                    HStack {
                        Menu("Category") {
                            Picker("lego", selection: $viewModel.partId) {
                                if partCategoriesVM.isLoading {
                                    Text("Loading...")
                                } else {
                                    ForEach(partCategoriesVM.categories, id: \.id) { cat in
                                        Text(cat.name)
                                            .tag(String(cat.id))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(width: 140, height: 40)
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
                .padding(.horizontal)
                
                partCard
            }
        }
        .task {
            await partCategoriesVM.loadAllPartCategories()
        }
        .onChange(of: partCategoriesVM.categories) { _, newValue in
            guard viewModel.partId.isEmpty, let first = newValue.first else { return }
            viewModel.partId = String(first.id)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Lego Parts")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.primary)
                Spacer()
            }
            SearchBar(searchText: $viewModel.searchText)
        }
        .onSubmit {
            viewModel.searchLegoParts()
            viewModel.searchLegoPartWithAPartId()
        }
        .padding(.horizontal)
    }
    
    private var partCard: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 2),
                spacing: 24) {
                    if let parts = viewModel.searchLegoPart {
                        ForEach(parts, id: \.partNumber) { part in
                            listPartItem(lego: part)
                        }
                    }
                }
                .padding(.horizontal)
        }
        .onAppear {
            viewModel.getPart()
        }
        .zIndex(showDropdown ? 1 : 100)
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

