//
//  CategoryCard.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/12/25.
//

import SwiftUI


// MARK: - Category Card
struct CategoryCard: View {
    let category: CategoryItem
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Handle category selection
        }) {
            VStack(spacing: 8) {
                Text(category.icon)
                    .font(.title)
                
                Text(category.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(category.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(category.color.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isPressed ? Color.legoRed : .clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
    }
}

//#Preview {
//    CategoryCard()
//}
