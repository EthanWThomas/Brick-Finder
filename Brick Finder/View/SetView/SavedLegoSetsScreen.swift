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
            LazyVStack(spacing: 16) {
                ForEach(viewModel.legoDataModel, id: \.setNumber) { set in
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
            .onAppear {
                viewModel.fetchLocalResults()
            }
        }
    }
    
    private func listSavedSetItem(lego set: LegoSetsDataModel) -> some View {
        SavedSetDataCard(legoSet: set, setSavedDataVM: viewModel)
    }
    
}

//#Preview {
//    SavedLegoSetsView()
//}
