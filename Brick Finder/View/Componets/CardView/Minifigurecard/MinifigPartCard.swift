//
//  PartCard.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 9/17/25.
//

import SwiftUI

struct MinifigPartCard: View {
    let part: InventoryParts.PartResult
    
    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: part.part.partImageURL ?? "Unknown")) { phase in
                switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            
                    default:
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .overlay {
                                Image(systemName: "person,fill")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 24))
                            }
                }
            }
            
            VStack(spacing: 8) {
                Text(part.part.name ?? "No Name")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(part.part.partNumber ?? "No Part Number")
                    .font(.caption)
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
}


