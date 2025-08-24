//
//  SetsCardView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/17/25.
//

import SwiftUI

struct SetsCardView: View {
    var legoSet: LegoSet.SetResults
    
    @State private var isPressed = true
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: legoSet.setImageURL ?? "Unknown")) { phase in
                switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                    default:
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                }
            }
            .frame(width: 112, height: 112)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                ZStack {
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack {
                        Spacer()
                        HStack {
                            Text("\(legoSet.setNumber ?? "None")")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Spacer()
                        }
                    }
                    .padding(8)
                }
            )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(legoSet.name ?? "None")")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
//                        HStack(spacing: 6) {
//                            Text("\(legoSet.themeID)")
//                        }
                    }
                    Spacer()
                }
                
                // Stats
                HStack(spacing: 16) {
                    StatView(
                        value: "\(legoSet.numberOfParts ?? 0)",
                        label: "pleces",
                        icon: "cube.box",
                        color: .blue
                    )
                    
                    StatView(
                        value: "\(legoSet.year ?? 0)",
                        label: "year",
                        icon: "calendar",
                        color: .orange
                    )
                }
                
                // Footer
                HStack {
                    Text("\(legoSet.numberOfParts ?? 0) pleces (\(legoSet.year ?? 0))")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    Button("View Details") {
                        print("View details for \(String(describing: legoSet.name))")
                    }
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(
                    color: .black.opacity(isPressed ? 0.15 : 0.05),
                    radius: isPressed ? 8 : 4,
                    x: 0,
                    y: isPressed ? 4 : 2
                )
                .scaleEffect(isPressed ? 0.99 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
                .onTapGesture {
                    print("Selected set: \(legoSet.name ?? "Unknown")")
                }
//                .onLongPressGesture(minimumDuration: 0) { pressing in
//                           isPressed = pressing
//                }
        )
    }
    
    
    
//    private func displayUrlImage(url: String?) -> some View {
//        AsyncImage(url: URL(string: url ?? "Unknown")) { phase in
//            switch phase {
//                case .empty:
//                    ProgressView()
//                case .success(let image):
//                    image
//                        .resizable()
//                default:
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.red)
//            }
//        }
//        .frame(width: 112, height: 112)
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .overlay(
//            ZStack {
//                LinearGradient(
//                    colors: [Color.clear, Color.black.opacity(0.3)],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                
//                VStack {
//                    HStack {
//                        Spacer()
//                        Text("\(legoSet.setNumber ?? "None")")
//                            .font(.system(size: 10, weight: .medium))
//                            .foregroundStyle(Color.white)
//                            .padding(.horizontal, 6)
//                            .padding(.vertical, 3)
//                            .background(.ultraThinMaterial)
//                            .clipShape(RoundedRectangle(cornerRadius: 8))
//                        Spacer()
//                    }
//                }
//                .padding(8)
//            }
//        )
//        
//    }
}

//#Preview {
//    SetsCardView(legoSet: LegoSet.SetResults)
//}
