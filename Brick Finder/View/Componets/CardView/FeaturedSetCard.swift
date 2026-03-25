//
//  FeaturedSetCard.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 3/24/26.
//

import SwiftUI

struct FeaturedSetCard: View {
    var setInfo: LegoSet.SetResults
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Image section (isolated + clipped so it can't visually overlap the text)
            ZStack(alignment: .bottomLeading) {
                displayUrlImage(url: setInfo.setImageURL)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .clipped()
                
                // Optional subtle gradient for legibility.
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.35)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 200)
                    .overlay(alignment: .bottomLeading) {
                        if let setNumber = setInfo.setNumber {
                            Text(setNumber)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .padding(12)
                        }
                    }
                    .allowsHitTesting(false)
            }
            
            // Text section
            Text(setInfo.name ?? "Unknown Set")
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            HStack(spacing: 8) {
                if let year = setInfo.year {
                    pill(text: "\(year)", systemImage: "calendar")
                }
                if let parts = setInfo.numberOfParts {
                    pill(text: "\(parts.formatted(.number)) parts", systemImage: "cube.box")
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 6)
    }
    
    private func displayUrlImage(url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "Unknown")) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color(.systemGray6)
                    ProgressView()
                }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .containerRelativeFrame(
                        .vertical, count: 5,
                        span: 2, spacing: 0
                    )
            default:
                Image("legoMinifigure")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6).opacity(0.2))
            }
        }
    }
    
    private func pill(text: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption)
            Text(text)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}
