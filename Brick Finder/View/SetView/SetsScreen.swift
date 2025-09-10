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
    
    var body: some View {
        NavigationStack {
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
                    Picker("Select Theme", selection: $viewModel.themeId) {
                        ForEach(LegoThemes.allCases, id: \.id) { theme in
                            Text(theme.displayName)
                                .tag(theme.rawValue)
                                .lineLimit(1)
                                .tint(Color.black)
                        }
                    }
                    .padding()
                    .frame(width: 150, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .stroke(Color.gray)
                            .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
                    )
                    Spacer()
                }
                .padding(.horizontal)
            
                // Filters
                listSetview
                .padding(.horizontal, -15)
            }
        }
        .onSubmit {
            viewModel.seacrhLegoSet()
            viewModel.searchLegoSetWithTheme()
            
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lego Sets")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.primary)
            
            // MARK: show the number of set find
            //                Text("Add set number here...")
            //                    .font(.system(size: 12))
            //                    .foregroundStyle(Color.secondary)
            SearchBar(searchText: $viewModel.searchText)
            
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
    //    @ViewBuilder
    //    private func optionsList(options: [String]) -> some View {
    //        ScrollView {
    //            VStack(alignment: .leading, spacing: 10) {
    //                ForEach(options, id: \.self) { option in
    //                    Text(option)
    //                        .padding(.horizontal, 15)
    //                        .padding(.vertical, 10)
    //                        .frame(maxWidth: .infinity, alignment: .leading)
    //                        .background(viewModel.themeId == option ? Color.blue.opacity(0.2) : Color.clear)
    //                        .onTapGesture {
    //                            withAnimation(.snappy) {
    //                                viewModel.themeId = option
    //                                showDropdown = false
    //                            }
    //                        }
    //                }
    //            }
    //            .background(Color.white)
    //        }
    //        .frame(width: 150, height: 200) // Match the width of the button and give it a max height
    //        .cornerRadius(15)
    //        .shadow(radius: 5)
    //        .offset(y: 100) // Adjust this to position it under the button
    //        .zIndex(200) // Ensure it's on top of everything
    //    }
    
    //    @StateObject var viewModel = SetVM()
    //    @StateObject var inventoryVM = InventoryPartsVM()
    //
    //    @State private var isSearching = false
    //
    //    var body: some View {
    //        NavigationStack {
    //            searchlegoSetView
    //            Section("Lego Set") {
    //                listOfSet
    //            }
    //        }
    //    }
    //
    //    private var searchlegoSetView: some View {
    //        VStack {
    //            topHStack
    //            bottomHStack
    //        }
    //        .onSubmit {
    //            viewModel.searchLegoSetWithTheme()
    //            viewModel.searchLegoSetWithAThemeAndYear()
    //        }
    //    }
    //
    //    private var listOfSet: some View {
    //        List {
    //            if let legoSet = viewModel.searchLegoSet {
    //                ForEach(legoSet, id: \.setNumber) { set in
    //                    listSetItem(lego: set)
    //                }
    //            }
    //        }
    //        .onAppear {
    //            viewModel.getLegoSet()
    //        }
    //    }
    //
    //    private var topHStack: some View {
    //        HStack(spacing: 1) {
    //            SearchBar(searchText: $viewModel.searchText)
    //            Picker("Select Theme", selection: $viewModel.themeId) {
    //                ForEach(LegoThemes.allCases, id: \.id) { theme in
    //                    Text(theme.displayName)
    //                        .tag(theme.rawValue)
    //                        .lineLimit(1)
    //                        .tint(Color.black)
    //                }
    //            }
    //            .padding()
    //            .frame(width: 170, height: 50)
    //            .background(
    //                RoundedRectangle(cornerRadius: 10)
    //                    .fill(Color.white)
    //                    .stroke(Color.gray)
    //                    .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
    //            )
    //            Spacer(minLength: 15)
    //        }
    //    }
    //
    //    private var bottomHStack: some View {
    //        HStack {
    //            Spacer()
    //            minimumpickerSelectionView
    //            Spacer(minLength: 40)
    //            maximumPickerSelectionView
    //            Spacer(minLength: 15)
    //        }
    //    }
    //
    //    private var minimumpickerSelectionView: some View {
    //        Picker("Minimum", selection: $viewModel.minYear) {
    //            ForEach(1949...2025, id: \.self) { minimumYear in
    //                Text(minimumYear.formatted(.number))
    //            }
    //        }
    //        .padding()
    //        .frame(width: 150, height: 50)
    //        .background(
    //            RoundedRectangle(cornerRadius: 10)
    //                .fill(Color.white)
    //                .stroke(Color.gray)
    //                .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
    //        )
    //    }
    //
    //    private var maximumPickerSelectionView: some View {
    //        Picker("maximum", selection: $viewModel.maxYear) {
    //            ForEach(1949...2025, id: \.self) { maximumYear in
    //                Text(maximumYear.formatted(.number))
    //            }
    //        }
    //        .padding()
    //        .frame(width: 150, height: 50)
    //        .background(
    //            RoundedRectangle(cornerRadius: 10)
    //                .fill(Color.white)
    //                .stroke(Color.gray)
    //                .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
    //        )
    //    }
}

#Preview {
    SetsScreen()
}
