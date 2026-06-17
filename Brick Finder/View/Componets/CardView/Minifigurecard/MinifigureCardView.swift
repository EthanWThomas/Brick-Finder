//
//  MinifigureCardView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 9/12/25.
//

import SwiftUI

struct MinifigureCardView: View {
    let minifigures: Lego.LegoResults
    
    @State var minifigureSavedDataVM: SavedMinifiguresVM
    
    // Fixed dimensions shared by every card so the grid lines up perfectly,
    // regardless of the incoming image's aspect ratio or the name's length.
    private let imageHeight: CGFloat = 120
    private let cardHeight: CGFloat = 236
    // Reserves room for a two-line name so single-line names don't shrink the
    // card and push the button row up to a different vertical position.
    private let nameBlockHeight: CGFloat = 36

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            imageContainer

            infoBlock

            // Absorbs any leftover space so all content stays top-aligned and
            // every card ends up exactly `cardHeight` tall.
            Spacer(minLength: 0)
        }
        .padding(12)
        // Fill the grid cell's width, then pin the height for a uniform card.
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    /// A fixed-size, centered image well. The image is resized + scaled to fit
    /// inside a constant frame and clipped, so no image — tall, wide, or
    /// oddly-padded — can warp the card.
    private var imageContainer: some View {
        AsyncImage(url: URL(string: minifigures.setImageURL ?? "Unknown")) { phase in
            switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                default:
                    Image("legoMinifigure")
                        .resizable()
                        .scaledToFit()
                        .padding(16)
            }
        }
        // Constant well: full cell width × fixed height, content centered.
        .frame(maxWidth: .infinity)
        .frame(height: imageHeight)
        .background(Color(.systemGray6))
        .clipped()
        .cornerRadius(8)
    }

    /// Name + metadata/action row. The name reserves a constant height so the
    /// row below always sits at the same spot across cards.
    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(minifigures.name ?? "Person")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, minHeight: nameBlockHeight, alignment: .topLeading)

            HStack {
                Text(minifigures.setNum ?? "00001")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )

                Spacer(minLength: 8)

                Button {
                    minifigureSavedDataVM.savedLegoResult(legoResult: minifigures)
                } label: {
                    Text("Save")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(Color.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

