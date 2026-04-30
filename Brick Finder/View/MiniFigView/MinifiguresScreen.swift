//
//  MinifiguresView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI
import SwiftData

struct MinifiguresScreen: View {
    @StateObject var minifiguresVM = MinifiguresVM()
    @StateObject var minifigSetVM = MiniFiguresDetailVM()
    @StateObject var minifigPartVM = PartVM()
    
    @State private var showDropdown = false
    
    @State var minifigurSavedDataVM: SavedMinifiguresVM
    
    init(context: ModelContext) {
        self.minifigurSavedDataVM = SavedMinifiguresVM(context: context)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                headerView
                
                tabbar
                
                miniFiguresGrid
                
            }
            .background(Color(UIColor.secondarySystemBackground))
            .onTapGesture {
                if showDropdown {
                    withAnimation {
                        showDropdown = false
                    }
                }
            }
            .onChange(of: minifiguresVM.themeId) { _, _ in
                minifiguresVM.seacrhMinifiguresWithAThemeId()
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Lego Minifigures")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.primary)
                Spacer()
            }
            SearchBar(searchText: $minifiguresVM.seacrhText)
        }
        .onSubmit {
            minifiguresVM.seacrhMinifigures()
            minifiguresVM.seacrhMinifiguresWithAThemeId()
        }
        .padding(.horizontal)
    }
    
    private var tabbar: some View {
        HStack {
            Menu("Theme") {
                Picker("lego", selection: $minifiguresVM.themeId) {
                    ForEach(LegoThemes.allCases, id: \.id) { theme in
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
        .padding(.horizontal)
    }
    
    private var miniFiguresGrid: some View {
        ScrollView {
            if minifiguresVM.isLoading {
                ProgressView("Loading minifigures")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else if let errorMessage = minifiguresVM.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Couldn’t load Minifigures")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else if let minifigures = minifiguresVM.searchMinifigures, !minifigures.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                    
                ], spacing: 16) {
                    ForEach(minifigures, id: \.setNum) { legoMinifigures in
                        listMinifigItem(lego: legoMinifigures)
                    }
                }
                .padding(.horizontal)
            } else if minifiguresVM.miniFigures != nil {
                VStack(spacing: 12) {
                    Image(systemName: "text.magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Search for a Minifigures")
                        .font(.headline)
                    Text("Type any Minifigure name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            }
        }
        .onAppear {
            minifiguresVM.getMiniFigures()
        }
        .zIndex(showDropdown ? 1 : 100)
    }
    
    private func listMinifigItem(lego minifigures: Lego.LegoResults) -> some View {
        NavigationLink {
            MinifiguresDetailView(
                minifigure: minifigures,
                minifigureInSetTheyCameIn: minifigSetVM,
                partVM: minifigPartVM)
        } label: {
            MinifigureCardView(minifigures: minifigures, minifigureSavedDataVM: minifigurSavedDataVM)
        }
    }
}

