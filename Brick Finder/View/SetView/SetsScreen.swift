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
            }
        }
        .onSubmit {
            viewModel.seacrhLegoSet()
            viewModel.searchLegoSetWithTheme()
            viewModel.searchLegoSetWithAThemeAndYear()
        }
    }
    
    private var themePicker: some View {
        HStack {
            Menu("Theme") {
                Picker("lego", selection: $viewModel.themeId) {
                    ForEach(LegoThemes.allCases, id: \.id) { theme in
                        Text(theme.displayName)
                            .tag(theme.rawValue)
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
