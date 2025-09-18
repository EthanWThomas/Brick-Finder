//
//  MinifiguresDetailView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 9/15/25.
//

import SwiftUI

struct MinifiguresDetailView: View {
    let minifigure: Lego.LegoResults
    
    @StateObject var minifigureInSetTheyCameIn: MiniFiguresDetailVM
    @StateObject var partVM: PartVM
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSelection
                
                partSection
                
                setsSection
            }
            .onAppear {
                partVM.getminifigePart(figNumber: minifigure.setNum ?? "Not Found")
                minifigureInSetTheyCameIn.getMinifigInSetCameIn(figNumber: minifigure.setNum ?? "Not Found")
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .top)
    }
    
    private var heroSelection: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.99, green: 0.94, blue: 0.54),
                    Color(red: 0.97, green: 0.8, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                HStack(alignment: .center, spacing: 32) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(minifigure.setNum ?? "No set number")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            Spacer()
                        }
                        
                        Text(minifigure.name ?? "No name")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        // CTA Button
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "person.2")
                                Text("Add to Collection")
                            }
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 0.2), value: false)
                    }
                    
                    Spacer()
                    
                    VStack {
                        AsyncImage(url: URL(string: minifigure.setImageURL ?? "Unknown")) { phase in
                            switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150)
                                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                                        .scaleEffect(1.02)
                                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: true)
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
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.vertical, 48)
            }
            .frame(minHeight: 500)
        }
    }
    
    private var partSection: some View {
        VStack(spacing: 32) {
            Text("Minifigure Parts")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), content:  {
                if let parts = partVM.inventoryPart {
                    ForEach(parts, id: \.id) { part in
                        MinifigPartCard(part: part)
                    }
                }
            })
            .padding(.horizontal, 15)
        }
        .onSubmit {
            partVM.getminifigePart(figNumber: minifigure.setNum ?? "Not Found")
        }
//        .padding(.vertical, 48)
    }
    
    private var setsSection: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("This Minifigure Set it appears in")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Discover all the amazing LEGO sets featuring this minifigure")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 24) {
                if let minifigInSetCameIn = minifigureInSetTheyCameIn.minifigInSet {
                    ForEach(minifigInSetCameIn, id: \.setNum) { legoSet in
                        MinifigureSetCard(lego: legoSet)
                    }
                }
            }
            .padding(.horizontal, 32)
//            if let set = minifigureInSetTheyCameIn.minifigInSet {
//                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 24) {
//                    ForEach(set, id: \.setNum) { legoSet in
//                        MinifigureSetCard(lego: legoSet)
//                    }
//                }
//                .padding(.horizontal, 32)
//            }
        }
        .onSubmit {
            minifigureInSetTheyCameIn.getMinifigInSetCameIn(figNumber: minifigure.setNum ?? "Not Found")
        }
        .padding(.vertical, 48)
        .background(Color(.systemGray6).opacity(0.5))
    }
}

