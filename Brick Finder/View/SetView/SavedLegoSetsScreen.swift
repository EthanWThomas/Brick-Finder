//
//  SavedLegoSetsView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 10/22/25.
//

import SwiftUI
import SwiftData

struct SavedLegoSetsScreen: View {
    
    @State var viewModel: SavedLegoSetsVM
    
    @StateObject private var setVM = SetVM()
    @StateObject private var inventoryVM = InventoryPartsVM()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var savedSets: [LegoSetsDataModel] {
        viewModel.legoDataModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if savedSets.isEmpty {
                    emptyStateView
                } else {
                    VStack(alignment: .leading, spacing: 24) {
                        listView
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .onAppear {
                viewModel.fetchLocalResults()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Text("No saved sets yet")
                .font(.headline)
            Text("Go save a set to start your collection!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(savedSets, id: \.setNumber) { set in
                    listSavedSetItem(lego: set)
                        .swipeActions {
                            Button {
                                viewModel.deleteLegoResult(lego: set)
                            } label: {
                                Image(systemName: "trash.fill")
                                    .tint(Color.red)
                            }
                        }
                }
            }
            .padding(.horizontal)
            .adaptiveReadableWidth(AdaptiveLayout.ContentWidth.standard, sizeClass: horizontalSizeClass)
        }
    }
    
    private func listSavedSetItem(lego set: LegoSetsDataModel) -> some View {
        NavigationLink {
            SavedSetDetailView(
                legoSet: set,
                viewModel: setVM,
                inventoryVM: inventoryVM)
        } label: {
            SavedSetDataCard(legoSet: set, setSavedDataVM: viewModel)
        }
    }
    
}

//#Preview {
//    SavedLegoSetsView()
//}
