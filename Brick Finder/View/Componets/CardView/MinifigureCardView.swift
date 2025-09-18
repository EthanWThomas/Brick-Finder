//
//  MinifigureCardView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 9/12/25.
//

import SwiftUI

struct MinifigureCardView: View {
    let minifigures: Lego.LegoResults
    
    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: minifigures.setImageURL ?? "Unknown")) { phase in
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
                                Image(systemName: "person,fill")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 24))
                            }
                }
            }
            .frame(height: 120)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(minifigures.name ?? "Person")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)
                
                Text(minifigures.setNum ?? "00001")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        
    }
}

