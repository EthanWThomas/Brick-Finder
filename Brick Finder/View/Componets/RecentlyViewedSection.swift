//
//  RecentlyViewedSection.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 1/13/26.
//

import SwiftUI
import SwiftData

struct RecentlyViewedSection: View {
//    @Query(sort: \ViewedItem.timestamp, order: .reverse)
    var history: ViewedItem
    
    var body: some View {
        VStack(spacing: 8) {
            displayUrl
                .frame(width: 100, height: 100)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(history.name ?? "Item has no name yet.")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                HStack {
                    Text(history.setNum ?? "Item has no set/part number yet.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(history.timestamp, style: .time)
                        .font(.callout)
                        .foregroundStyle(Color.gray.opacity(0.7))
                }
            }
            .padding(12)
//            .background(Color(.systemBackground))
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
    
    private var displayUrl: some View {
        AsyncImage(url: URL(string: history.imageURL ?? "Unkonwn URL")) { phase in
            switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "square.and.arrow.up.fill")
                                .foregroundStyle(Color.gray)
                                .font(.system(size: 24))
                        }
            }
        }
    }
}

