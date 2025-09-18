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
        NavigationStack {
            VStack(spacing: 24) {
                headerView
                
                HStack {
                    CustomDropdownPicker(
                        hint: "Theme",
                        selection: $minifiguresVM.themeId,
                        showDropdown: $showDropdown
                    )
                    Spacer()
                }
                .padding(.horizontal)
                .zIndex(showDropdown ? 1000 : 1)
                
                miniFiguresGrid
                
            }
            //        .overlay(alignment: .topLeading) {
            //            if showDropdown {
            //                VStack(alignment: .leading, spacing: 0) {
            //                    ScrollView {
            //                        ForEach(LegoThemes.allCases, id: \.id) { option in
            //                            Button {
            //                                withAnimation {
            //                                    minifiguresVM.themeId = option.rawValue
            //                                    showDropdown = false
            //                                }
            //                            } label: {
            //                                Text(option.displayName)
            //                                    .padding(.horizontal, 12)
            //                                    .padding(.vertical, 10)
            //                                    .frame(maxWidth: .infinity, alignment: .leading)
            //                                    .background(minifiguresVM.themeId == option.rawValue ? Color.blue.opacity(0.1) : Color.clear)
            //                            }
            //                            .buttonStyle(PlainButtonStyle())
            //                        }
            //                    }
            //                }
            //                .frame(width: 150, height: 200) // Match the width and give a max height
            //                .background(Color(.systemBackground))
            //                .cornerRadius(8)
            //                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            //                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray4), lineWidth: 1))
            //                // Use a Spacer to push the overlay down to the correct position
            //                // or an offset if you have a consistent header height.
            //                .padding(.top, 100) // Adjust this value to position it correctly
            //                .padding(.leading, 20)
            //                .zIndex(200) // Ensure it's on top of everything
            //            }
            //        }
            .onTapGesture {
                if showDropdown {
                    withAnimation {
                        showDropdown = false
                    }
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
                        listMinifigItem(lego: legoMinifigures)
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
    
    private func listMinifigItem(lego minifigures: Lego.LegoResults) -> some View {
        NavigationLink {
            MinifiguresDetailView(
                minifigure: minifigures,
                minifigureInSetTheyCameIn: minifigSetVM,
                partVM: minifigPartVM)
        } label: {
            MinifigureCardView(minifigures: minifigures)
        }
    }
}

#Preview {
    MinifiguresScreen()
}
