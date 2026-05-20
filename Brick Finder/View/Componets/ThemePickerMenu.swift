//
//  ThemePickerMenu.swift
//  Brick Finder
//

import SwiftUI

/// Theme filter control used on Sets and Minifigures screens (matches Parts category picker styling).
struct ThemePickerMenu: View {
    @Binding var themeId: String
    @ObservedObject var themeViewModel: ThemeViewModel

    var body: some View {
        Menu("Theme") {
            Picker("lego", selection: $themeId) {
                Text("All Themes")
                    .tag("")

                if themeViewModel.isLoading && themeViewModel.themes.isEmpty {
                    Text("Loading…")
                        .tag("")
                } else if themeViewModel.sortedThemes.isEmpty {
                    Text(themeViewModel.errorMessage ?? "No themes available")
                        .tag("")
                } else {
                    ForEach(themeViewModel.sortedThemes) { theme in
                        Text(theme.name)
                            .tag(theme.idString)
                    }
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
    }
}
