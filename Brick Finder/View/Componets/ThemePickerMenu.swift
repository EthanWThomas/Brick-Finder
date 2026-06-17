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
                // Reset / "show everything" option always stays pinned at the top.
                Text("All Themes")
                    .tag("")

                if themeViewModel.isLoading && themeViewModel.themes.isEmpty {
                    Text("Loading…")
                        .tag("")
                } else if themeViewModel.sortedThemes.isEmpty {
                    Text(themeViewModel.errorMessage ?? "No themes available")
                        .tag("")
                } else {
                    // Curated, recognizable themes float to the top for quick access.
                    if !themeViewModel.popularThemes.isEmpty {
                        Section("Popular Themes") {
                            ForEach(themeViewModel.popularThemes) { theme in
                                Text(theme.name)
                                    .tag(theme.idString)
                            }
                        }
                    }

                    // Everything else, alphabetized.
                    Section("Other Themes") {
                        ForEach(themeViewModel.otherThemes) { theme in
                            Text(theme.name)
                                .tag(theme.idString)
                        }
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

/// Entry point control that opens the new `ThemeFilterMenuView` pop-up.
///
/// This replaces the old `ThemePickerMenu` (still defined above and kept as a
/// fallback). To revert, swap `ThemeButton(...)` back to `ThemePickerMenu(...)`
/// at the call sites — both take the same `themeId` / `themeViewModel` inputs.
struct ThemeButton: View {
    @Binding var themeId: String
    @ObservedObject var themeViewModel: ThemeViewModel

    /// Drives presentation of the theme browser sheet.
    @State private var showThemeFilter = false

    var body: some View {
        Button {
            showThemeFilter = true
        } label: {
            HStack(spacing: 6) {
                Text(selectedTitle)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Image(systemName: "chevron.down")
                    .font(.caption2)
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
        .sheet(isPresented: $showThemeFilter) {
            ThemeFilterMenuView(themeId: $themeId, themeViewModel: themeViewModel)
        }
    }

    /// Shows the selected theme's name on the button, or "Theme" when cleared.
    private var selectedTitle: String {
        guard !themeId.isEmpty else { return "Theme" }
        return themeViewModel.theme(withIdString: themeId)?.name ?? "Theme"
    }
}
