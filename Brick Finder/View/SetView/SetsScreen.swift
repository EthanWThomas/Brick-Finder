//
//  SetsView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI

struct SetsScreen: View {
    @StateObject var viewModel = SetVM()
    
    @State private var isSearching = false
    
    var body: some View {
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
//            HStack(spacing: 12) {
//                Picker("Theme", selection: $viewModel.themeId) {
//                    ForEach(LegoThemes.allCases, id: \.id) { theme in
//                        Text(theme.displayName)
//                            .tag(theme.rawValue)
//                            .lineLimit(1)
//                            .tint(Color.black)
//                    }
//                }
//            }
//            .padding(.horizontal)
//            Spacer()
            
            // Filters
            ScrollView(.vertical, showsIndicators: false) {
                listSetview
            }
            .padding(.horizontal, -15)
            
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
        LazyVStack(spacing: 16) {
            if let legoSet = viewModel.searchLegoSet {
                ForEach(legoSet, id: \.setNumber) { set in
                    SetsCardView(legoSet: set)
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.getLegoSet()
        }
    }
    
}

#Preview {
    SetsScreen()
}
