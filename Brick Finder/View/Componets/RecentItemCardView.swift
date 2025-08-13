//
//  RecentItemCardView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/12/25.
//

import SwiftUI

// MARK: - Recent Item Card
struct RecentItemCardView: View {
    let item: RecentItem
      
      var body: some View {
          VStack(spacing: 0) {
              // Image placeholder
              ZStack {
                  LinearGradient(
                      colors: [.legoRed, .legoRed.opacity(0.8)],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                  )
                  .frame(height: 100)
                  
                  Text(item.icon)
                      .font(.largeTitle)
              }
              
              VStack(alignment: .leading, spacing: 4) {
                  HStack {
                      Text(item.title)
                          .font(.subheadline)
                          .fontWeight(.semibold)
                          .foregroundColor(.primary)
                      Spacer()
                  }
                  
                  HStack {
                      Text(item.subtitle)
                          .font(.caption)
                          .foregroundColor(.secondary)
                      Spacer()
                  }
              }
              .padding(12)
          }
          .background(Color(.systemBackground))
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
      }
  }

//#Preview {
//    RecentItemCardView()
//}
