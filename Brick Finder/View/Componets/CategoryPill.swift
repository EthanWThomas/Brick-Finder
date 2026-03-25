//
//  CategoryPill.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 3/17/26.
//

import SwiftUI

struct CategoryPill: View {
    let theme: Themes.ThemesResults
    let isSelected: Bool
    
    var body: some View {
        Text(theme.theme ?? "No Theme")
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isSelected ? Color.black : Color.white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(20)
    }
}
