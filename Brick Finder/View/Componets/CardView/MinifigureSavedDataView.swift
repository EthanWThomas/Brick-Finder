//
//  MinifigureSavedDataView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 12/20/25.
//

import SwiftUI

struct MinifigureSavedDataView: View {
    @State private var isPressed = false
    var body: some View {
        VStack(spacing: 8) {
            Image("minifigure")
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
            
            Text("Minifigure")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(Color.primary.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPressed ? Color.legoRed : .clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

#Preview {
    MinifigureSavedDataView()
}
