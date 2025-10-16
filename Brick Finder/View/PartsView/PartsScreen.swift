//
//  PartsView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI

struct PartsScreen: View {
    @StateObject var viewModel = PartVM()
    
    @State private var showDropdown = false
    
    var body: some View {
        VStack(spacing: 24) {
            header
            
            HStack {
                HStack {
                    Menu("Category") {
                        Picker("lego", selection: $viewModel.partId) {
                            ForEach(PartCategory.allCases, id: \.id) { theme in
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
            .padding(.horizontal)
            
            partCard
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
                            PartCard(part: part)
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
}

#Preview {
    PartsScreen()
}
