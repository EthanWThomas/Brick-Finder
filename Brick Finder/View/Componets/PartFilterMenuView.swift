//
//  PartFilterMenuView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 6/16/26.
//

import SwiftUI

/// A pop-up part-category browser presented as a sheet from `PartButton`.
///
/// Layout:
///   • A pinned "All Categories" reset row.
///   • A "Popular Categories" section with curated, commonly browsed categories.
///   • One section per starting letter (A, B, C …) for every remaining category.
///
/// Selecting any row writes the chosen `part_cat_id` back through
/// `partCategoryId` and immediately dismisses the sheet ("backs out"), so the
/// Parts screen reacts via its existing `onChange(of:)` filter logic.
struct PartFilterMenuView: View {
    /// The currently selected `part_cat_id` (empty string == "All Categories").
    @Binding var partCategoryId: String
    /// Shared source of truth for the fetched + grouped categories.
    @ObservedObject var partCategoryViewModel: PartCategoryViewModel

    /// Lets us dismiss the sheet the moment a category is tapped.
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // Reset option: clears the filter and shows every part.
                resetRow

                if partCategoryViewModel.isLoading && partCategoryViewModel.categories.isEmpty {
                    // First load with nothing cached yet.
                    loadingRow
                } else if partCategoryViewModel.sortedCategories.isEmpty {
                    // Fetch failed and we have no cache to fall back on.
                    emptyRow
                } else {
                    // Curated favourites pinned to the very top for quick access.
                    if !partCategoryViewModel.popularCategories.isEmpty {
                        Section("Popular Categories") {
                            ForEach(partCategoryViewModel.popularCategories) { category in
                                categoryRow(category)
                            }
                        }
                    }

                    // Everything else, grouped into A–Z section headers.
                    ForEach(partCategoryViewModel.alphabeticalSections) { section in
                        Section(section.title) {
                            ForEach(section.categories) { category in
                                categoryRow(category)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Choose a Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            // Idempotent: only kicks off a fetch if categories aren't loaded yet.
            .task { partCategoryViewModel.loadCategoriesIfNeeded() }
        }
        // A roomy popup that can still be dragged down to a half sheet.
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Rows

    /// "All Categories" reset row, checked when no filter is active.
    private var resetRow: some View {
        Button {
            select("")
        } label: {
            selectableRow(title: "All Categories", isSelected: partCategoryId.isEmpty)
        }
        .buttonStyle(.plain)
    }

    /// A single tappable category row with a trailing checkmark when selected.
    private func categoryRow(_ category: PartCategory) -> some View {
        Button {
            select(category.idString)
        } label: {
            selectableRow(title: category.name, isSelected: partCategoryId == category.idString)
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
            Text("Loading categories…")
                .foregroundStyle(.secondary)
        }
    }

    private var emptyRow: some View {
        Text(partCategoryViewModel.errorMessage ?? "No categories available")
            .foregroundStyle(.secondary)
    }

    // MARK: - Selection

    /// Commits the selection and dismisses the popup.
    private func select(_ id: String) {
        partCategoryId = id
        dismiss()
    }
}
