//
//  SearchBar.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/12/25.
//

import SwiftUI

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search sets, parts, minifigs...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

//#Preview {
//    SearchBar()
//}
