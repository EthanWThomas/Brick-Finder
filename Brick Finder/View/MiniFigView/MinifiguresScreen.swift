//
//  MinifiguresView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI

struct MinifiguresScreen: View {
    @StateObject var minifiguresVM = MinifiguresVM()
    @StateObject var minifigSetVM = MiniFiguresDetailVM()
    @StateObject var minifigPartVM = PartVM()
    
    @State private var showDropdown = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Filters
                HStack(spacing: 12) {
                    CustomDropdownPicker(
                        hint: "Theme",
                        options: LegoThemes.allCases,
                        selection: $minifiguresVM.themeId,
                        showDropdown: $showDropdown
                    )
                    Spacer()
                }
                
                .padding(.horizontal)
                .zIndex(showDropdown ? 1000 : 1)
                
                // Minfigures
                miniFiguresGrid
            }
        }
        .onTapGesture {
            if showDropdown {
                withAnimation {
                    showDropdown = false
                }
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
    
    private var miniFiguresGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
                
            ], spacing: 16) {
                if let minifigures = minifiguresVM.searchMinifigures {
                    ForEach(minifigures, id: \.setNum) { legoMinifigures in
                        MinifigureCardView(minifigures: legoMinifigures)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            minifiguresVM.getMiniFigures()
        }
        .zIndex(showDropdown ? 1 : 100)
    }
}

#Preview {
    MinifiguresScreen()
}
