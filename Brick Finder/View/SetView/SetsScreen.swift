//
//  SetsView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI

struct SetsScreen: View {
    @StateObject var viewModel = SetVM()
    @StateObject var inventoryVM = InventoryPartsVM()
    
    @State private var isSearching = false
    @State private var showDropdown = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Lego Sets")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.primary)
                            Spacer()
                        }
                        
                        SearchBar(searchText: $viewModel.searchText)
                    }
                    .padding(.horizontal)
                    HStack(spacing: 12) {
                        CustomDropdownPicker(
                            hint: "Theme",
                            selection: $viewModel.themeId,
                            showDropdown: $showDropdown)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Filters
                    listSetview
                        .padding(.horizontal, -15)
                }
            }
        }
        .onSubmit {
            viewModel.seacrhLegoSet()
            viewModel.searchLegoSetWithTheme()
            
        }
    }
    
    private var listSetview: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let legoSet = viewModel.searchLegoSet {
                    ForEach(legoSet, id: \.setNumber) { set in
                        listSetItem(lego: set)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.getLegoSet()
        }
    }
    
    private func listSetItem(lego set: LegoSet.SetResults) -> some View {
        NavigationLink {
            SetDetailView(
                legoSet: set,
                viewModel: viewModel,
                inventoryVM: inventoryVM)
        } label: {
            SetsCardView(legoSet: set)
        }
    }
}

#Preview {
    SetsScreen()
}
