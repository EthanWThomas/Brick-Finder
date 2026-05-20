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
