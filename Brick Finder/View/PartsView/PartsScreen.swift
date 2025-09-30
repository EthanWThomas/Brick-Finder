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
//                CustomDropdownPicker(
//                    hint: "Part Number",
//                    selection: $viewModel.partId,
//                    showDropdown: $showDropdown)
                Spacer()
            }
            .padding(.horizontal)
            .zIndex(showDropdown ? 1000 : 1)
            
            partCard
        }
        .onTapGesture {
            if showDropdown {
                withAnimation {
                    showDropdown = false
                }
            }
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
