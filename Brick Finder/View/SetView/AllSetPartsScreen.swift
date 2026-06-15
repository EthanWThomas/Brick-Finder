//
//  AllSetPartsScreen.swift
//  Brick Finder
//
//  Full, scrollable inventory of every part in a set. Reuses the same card
//  layout as the set detail parts tab and keeps lazily paging the Rebrickable
//  API as the user scrolls, so even very large sets show their entire
//  inventory.
//

import SwiftUI

struct AllSetPartsScreen: View {
    let setName: String
    @ObservedObject var inventoryVM: InventoryPartsVM

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ScrollView(.vertical) {
            if let parts = inventoryVM.setInventoryPart {
                if parts.isEmpty {
                    emptyState
                } else {
                    countHeader(loadedCount: parts.count)
                        .padding(.horizontal, 15)
                        .padding(.top, 12)

                    LazyVGrid(columns: AdaptiveLayout.cardColumns(minimum: 150)) {
                        ForEach(parts, id: \.id) { legoPart in
                            SetPartCardView(
                                imageURL: legoPart.part.partImageURL,
                                partNumber: legoPart.part.partNumber,
                                quantity: legoPart.quantity)
                                .onAppear {
                                    inventoryVM.loadMorePartsIfNeeded(currentItem: legoPart)
                                }
                        }
                    }
                    .padding(15)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    if inventoryVM.isLoadingMoreParts {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 16)
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            }
        }
        .scrollIndicators(.automatic)
        .safeAreaPadding(.bottom, 8)
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Parts")
        .navigationBarTitleDisplayMode(.inline)
        .adaptiveReadableWidth(AdaptiveLayout.ContentWidth.detail, sizeClass: horizontalSizeClass)
    }

    @ViewBuilder
    private func countHeader(loadedCount: Int) -> some View {
        let total = max(inventoryVM.partsTotalCount, loadedCount)
        VStack(alignment: .leading, spacing: 4) {
            Text(setName)
                .font(.headline)
                .lineLimit(2)

            Text("Showing \(loadedCount) of \(total) parts")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "cube.box")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("This set has no parts")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}
