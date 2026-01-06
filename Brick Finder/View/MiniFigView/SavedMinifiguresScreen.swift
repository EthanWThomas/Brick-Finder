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
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 24) {
                    listView
                }
            }
        }
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
            .onAppear {
                viewModel.fetchLocalResult()
            }
        }
    }
    
    private func listSavedMinifigureItem(lego minifigure: LegoDataModel) -> some View {
        SavedMinifigureDataCard(minifigures: minifigure, viewModel: viewModel)
    }
}


