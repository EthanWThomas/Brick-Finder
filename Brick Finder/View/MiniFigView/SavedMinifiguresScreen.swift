//
//  SavedMinifiguresScreen.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 1/4/26.
//

import SwiftUI
import SwiftData

struct SavedMinifiguresScreen: View {
    @State var viewModel: SavedMinifiguresVM
    
    @StateObject private var minifigSetVM = MiniFiguresDetailVM()
    @StateObject private var minifigPartVM = PartVM()
    
    private var savedMinifigures: [LegoDataModel] {
        viewModel.legoDataModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if savedMinifigures.isEmpty {
                    emptyStateView
                } else {
                    VStack(alignment: .leading, spacing: 24) {
                        listView
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .onAppear {
                viewModel.fetchLocalResult()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Text("No saved minifigures yet")
                .font(.headline)
            Text("Go save a minifigure to start your collection!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var listView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.legoDataModel, id: \.setNum) { minifigure in
                    listSavedMinifigureItem(lego: minifigure)
                }
            }
        }
    }
    
    private func listSavedMinifigureItem(lego minifigure: LegoDataModel) -> some View {
        NavigationLink {
            SavedMinifigureDetailView(
                minifigure: minifigure,
                minifigureInSetTheyCameIn: minifigSetVM,
                partVM: minifigPartVM)
        } label: {
            SavedMinifigureDataCard(minifigures: minifigure, viewModel: viewModel)
        }
    }
}


