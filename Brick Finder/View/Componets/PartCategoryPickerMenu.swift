//
//  PartCategoryPickerMenu.swift
//  Brick Finder
//

import SwiftUI

/// Part category filter control used on the Parts screen (matches Theme picker styling).
struct PartCategoryPickerMenu: View {
    @Binding var partCategoryId: String
    @ObservedObject var partCategoryViewModel: PartCategoryViewModel

    var body: some View {
        Menu("Category") {
            Picker("lego", selection: $partCategoryId) {
                Text("All Categories")
                    .tag("")

                if partCategoryViewModel.isLoading && partCategoryViewModel.categories.isEmpty {
                    Text("Loading…")
                        .tag("")
                } else if partCategoryViewModel.sortedCategories.isEmpty {
                    Text(partCategoryViewModel.errorMessage ?? "No categories available")
                        .tag("")
                } else {
                    ForEach(partCategoryViewModel.sortedCategories) { category in
                        Text(category.name)
                            .tag(category.idString)
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

/// Entry point control that opens the new `PartFilterMenuView` pop-up.
///
/// This replaces the old `PartCategoryPickerMenu` (still defined above and kept
/// as a fallback). To revert, swap `PartButton(...)` back to
/// `PartCategoryPickerMenu(...)` at the call site — both take the same
/// `partCategoryId` / `partCategoryViewModel` inputs.
struct PartButton: View {
    @Binding var partCategoryId: String
    @ObservedObject var partCategoryViewModel: PartCategoryViewModel

    /// Drives presentation of the category browser sheet.
    @State private var showPartFilter = false

    var body: some View {
        Button {
            showPartFilter = true
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
        .sheet(isPresented: $showPartFilter) {
            PartFilterMenuView(
                partCategoryId: $partCategoryId,
                partCategoryViewModel: partCategoryViewModel
            )
        }
    }

    /// Shows the selected category's name on the button, or "Category" when cleared.
    private var selectedTitle: String {
        guard !partCategoryId.isEmpty else { return "Category" }
        return partCategoryViewModel.category(withIdString: partCategoryId)?.name ?? "Category"
    }
}
