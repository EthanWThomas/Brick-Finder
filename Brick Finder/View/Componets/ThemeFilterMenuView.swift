//
//  ThemeFilterMenuView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 6/16/26.
//

import SwiftUI

/// A pop-up theme browser presented as a sheet from `ThemeButton`.
///
/// Layout:
///   • A pinned "All Themes" reset row.
///   • A "Popular Themes" section with curated, recognizable themes.
///   • One section per starting letter (A, B, C …) for every remaining theme.
///
/// Selecting any row writes the chosen `theme_id` back through `themeId` and
/// immediately dismisses the sheet ("backs out"), so the parent screen can
/// react via its existing `onChange(of:)` filter logic.
struct ThemeFilterMenuView: View {
    /// The currently selected `theme_id` (empty string == "All Themes").
    @Binding var themeId: String
    /// Shared source of truth for the fetched + grouped themes.
    @ObservedObject var themeViewModel: ThemeViewModel

    /// Lets us dismiss the sheet the moment a theme is tapped.
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // Reset option: clears the filter and shows every set/minifig.
                resetRow

                if themeViewModel.isLoading && themeViewModel.themes.isEmpty {
                    // First load with nothing cached yet.
                    loadingRow
                } else if themeViewModel.sortedThemes.isEmpty {
                    // Fetch failed and we have no cache to fall back on.
                    emptyRow
                } else {
                    // Curated favourites pinned to the very top for quick access.
                    if !themeViewModel.popularThemes.isEmpty {
                        Section("Popular Themes") {
                            ForEach(themeViewModel.popularThemes) { theme in
                                themeRow(theme)
                            }
                        }
                    }

                    // Everything else, grouped into A–Z section headers.
                    ForEach(themeViewModel.alphabeticalSections) { section in
                        Section(section.title) {
                            ForEach(section.themes) { theme in
                                themeRow(theme)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Choose a Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            // Idempotent: only kicks off a fetch if themes aren't loaded yet.
            .task { themeViewModel.loadThemesIfNeeded() }
        }
        // A roomy popup that can still be dragged down to a half sheet.
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Rows

    /// "All Themes" reset row, checked when no filter is active.
    private var resetRow: some View {
        Button {
            select("")
        } label: {
            selectableRow(title: "All Themes", isSelected: themeId.isEmpty)
        }
        .buttonStyle(.plain)
    }

    /// A single tappable theme row with a trailing checkmark when selected.
    private func themeRow(_ theme: LegoTheme) -> some View {
        Button {
            select(theme.idString)
        } label: {
            selectableRow(title: theme.name, isSelected: themeId == theme.idString)
        }
        .buttonStyle(.plain)
    }

    /// Shared row chrome so every option looks consistent.
    private func selectableRow(title: String, isSelected: Bool) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)
            }
        }
        // Make the whole row width tappable, not just the text.
        .contentShape(Rectangle())
    }

    private var loadingRow: some View {
        HStack {
            ProgressView()
            Text("Loading themes…")
                .foregroundStyle(.secondary)
        }
    }

    private var emptyRow: some View {
        Text(themeViewModel.errorMessage ?? "No themes available")
            .foregroundStyle(.secondary)
    }

    // MARK: - Selection

    /// Commits the selection and dismisses the popup.
    private func select(_ id: String) {
        themeId = id
        dismiss()
    }
}
