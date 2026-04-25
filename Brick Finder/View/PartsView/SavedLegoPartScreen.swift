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
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 24) {
                    listView
                }
            }
        }
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
                .onAppear {
                    viewModel.fechLocalResult()
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


