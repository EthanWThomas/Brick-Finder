//
//  CollectionCard.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 3/17/26.
//

import SwiftUI

struct CollectionCard: View {
    let title: String
    let image: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.opacity(0.1))
                Image(systemName: image)
                    .font(.title)
                    .foregroundColor(color)
            }
            .frame(height: 100)
            
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Text("View all items")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}
