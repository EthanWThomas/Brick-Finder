//
//  SetPartCardView.swift
//  Brick Finder
//
//  Shared card layout for a single inventory part in a set, so the set detail
//  parts tab and the full "all parts" screen render identically.
//

import SwiftUI

struct SetPartCardView: View {
    let imageURL: String?
    let partNumber: String?
    let quantity: Int

    var body: some View {
        VStack {
            displayUrlImage(url: imageURL)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)

            HStack(spacing: 8) {
                Text("\(quantity.formatted(.number)) x")
                    .foregroundStyle(Color("PartIdColor"))
                    .font(.headline)
                    .padding()
//                    .foregroundColor(.secondary)
                Text(partNumber ?? "no number")
                    .font(.caption)
                    .foregroundStyle(Color("PartIdColor"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(.systemGray6).opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: false)
        .frame(height: 210)
    }

    private func displayUrlImage(url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "Unknown")) { phase in
            switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    Image("legoMinifigure")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
            }
        }
    }
}
