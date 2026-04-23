//
//  CollectionCard.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 3/17/26.
//

import SwiftUI

struct CollectionCard: View {
    let title: String
    let photo: Photo
    let color: Color
    
    /// Hero image for the card — bundled asset or remote (e.g. Wikimedia Commons).
    enum Photo: Equatable {
        case asset(String)
        case remote(URL)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.opacity(0.1))
                photoContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.black)
            
            Text("View all items")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
    
    @ViewBuilder
    private var photoContent: some View {
        switch photo {
        case .asset(let name):
            Image(name)
                .resizable()
                .scaledToFit()
        case .remote(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .tint(color)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundStyle(color)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}
