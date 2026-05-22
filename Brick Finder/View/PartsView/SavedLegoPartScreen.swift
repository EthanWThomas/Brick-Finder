//
//  SavedLegoPartScreen.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 1/12/26.
//

import SwiftUI
import SwiftData

struct SavedLegoPartScreen: View {
    @State var viewModel: SavedLegoPartVM
    @StateObject var partViewModel = PartVM()
    
    private var savedParts: [LegoPartsDataModel] {
        viewModel.legoDataModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if savedParts.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 24) {
                        listView
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .onAppear {
                viewModel.fechLocalResult()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Text("No saved parts yet")
                .font(.headline)
            Text("Go save a part to start your collection!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var listView: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 2),
                spacing: 24) {
                    ForEach(viewModel.legoDataModel, id: \.partNumber) { part in
                        savedListPartItem(lego: part)
                    }
                }
        }
        
    }
    
    private func savedListPartItem(lego parts: LegoPartsDataModel) -> some View {
        NavigationLink {
            SavedPartDetailScreen(legoPart: parts, viewModel: partViewModel)
        } label: {
            SavedLegoPartDataCard(part: parts, viewModel: viewModel)
        }

    }
    
}


