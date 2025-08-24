//
//  SearchBar.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/12/25.
//

import SwiftUI

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(
                    searchText.isEmpty ? Color.secondary : Color.accentColor
                )
            
            TextField("Search sets, parts, minifigs...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .overlay(
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x: 10)
                        .foregroundStyle(Color.accentColor)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .onTapGesture {
                            searchText = ""
                        }
                    ,alignment: .trailing
                )
        }
        .font(.headline)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .stroke(Color.gray)
                .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

//#Preview {
//    SearchBar()
//}
