//
//  MinifigureSetCard.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 9/17/25.
//

import SwiftUI

struct MinifigureSetCard: View {
    let lego: Lego.LegoResults
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: lego.setImageURL ?? "Unknown")) { phase in
                    switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
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
                
                Text(lego.setNum ?? "No Number")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(lego.name ?? "No Name")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
                
                
               
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: false)
    }
}


