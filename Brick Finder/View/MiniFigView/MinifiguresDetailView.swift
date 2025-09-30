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
    
    @State private var isPressed = true
    
    @State private var selectedtab: MinifigureTab?
    @State private var tabProgress: CGFloat = 0
    @State private var dataLoadingTask: Task<Void, Never>? = nil
    
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        VStack(spacing: 0) {
            heroSelection
            
            customTabBar()
                .padding(.vertical, 18)
            
            minifiguresList
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var heroSelection: some View {
        VStack(spacing: 0) {
            VStack {
                displayUrlImage(url: minifigure.setImageURL)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            }
            .offset(x: 0, y: 55)
            .frame(maxWidth: .infinity)
            .background(Color.yellow)
            .padding(.bottom, 55)
            
            HStack(alignment: .center) {
                Text(minifigure.name ?? "Not Found")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding()
                    .foregroundColor(.primary)
                
                Text(minifigure.setNum ?? "Not Found")
                    .font(.footnote)
                    .accentColor(.gray)
                    .padding()
            }
        }
    }
    
    private var minifiguresList: some View {
        VStack(spacing: 16) {
            GeometryReader {
                let size = $0.size
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        partSection
                            .id(MinifigureTab.parts)
                            .containerRelativeFrame(.horizontal)
                        
                        setsSection
                            .id(MinifigureTab.sets)
                            .containerRelativeFrame(.horizontal)
                    }
                    .scrollTargetLayout()
                    .offsetX { value in
                        let progress = -value / (size.width * CGFloat(MinifigureTab.allCases.count - 1))
                        
                        tabProgress = max(min(progress, 1), 0)
                        
                    }
                }
                .scrollPosition(id: $selectedtab)
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.paging)
                .scrollClipDisabled()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.gray.opacity(0.1))
        .onAppear {
            partVM.getminifigePart(figNumber: minifigure.setNum ?? "Not Found")
            minifigureInSetTheyCameIn.getMinifigInSetCameIn(figNumber: minifigure.setNum ?? "Not Found")
        }
    }
    
    private var partSection: some View {
        ScrollView(.vertical) {
            VStack(spacing: 32) {
                Text("Minifigure Parts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), content:  {
                    if let parts = partVM.inventoryPart {
                        ForEach(parts, id: \.id) { part in
                            partCard(
                                image: part.part.partImageURL,
                                part: part.part.partNumber,
                                set: part.quantity)
    //                        MinifigPartCard(part: part)
                        }
                    }
                })
                .padding(15)
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
                .mask {
                    Rectangle()
                        .padding(.bottom, -100)
                }
            }
            .onSubmit {
                partVM.getminifigePart(figNumber: minifigure.setNum ?? "Not Found")
            }
        }
//        .padding(.vertical, 48)
    }
    
    private var setsSection: some View {
        ScrollView(.vertical) {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("This Minifigure Set it appears in")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                LazyVStack(spacing: 16) {
                    if let minifigInSetCameIn = minifigureInSetTheyCameIn.minifigInSet {
                        ForEach(minifigInSetCameIn, id: \.setNum) { legoSet in
                            setItCameInCard(
                                name: legoSet.name,
                                set: legoSet.setNum,
                                setUrl: legoSet.setImageURL,
                                numberOf: legoSet.numberOfPart)
                            //                        MinifigureSetCard(lego: legoSet)
                        }
                        .onSubmit {
                            minifigureInSetTheyCameIn.getMinifigInSetCameIn(figNumber: minifigure.setNum ?? "Not Found")
                        }
                    }
                }
                .padding(15)
               
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .mask {
                Rectangle()
                    .padding(.bottom, -100)
            }
//            .padding(.vertical, 48)
//            .background(Color(.systemGray6).opacity(0.5))
        }
    }
    
    private func partCard(image url: String?, part num: String?, set quantity: Int) -> some View {
        VStack {
            displayUrlImage(url: url)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                
            HStack(spacing: 8) {
                Text("\(quantity.formatted(.number)) x")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.secondary)
                
                Text(num ?? "no number")
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
    
    private func setItCameInCard(name: String?, set number: String?, setUrl url: String?, numberOf part: Int?) -> some View {
        HStack(spacing: 16) {
            displayUrlImage(url: url)
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
                                Text("\(number ?? "None")")
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
                        Text(name ?? "No Name yet")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    StatView(
                        value: "\(part ?? 0)",
                        label: "pleces",
                        icon: "cube.box",
                        color: .green)
                    
                }
                
                HStack {
                    Text("\(part ?? 0) pleces ")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
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
        )
    }
    
    private func displayUrlImage(url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "Unknown")) { phase in
            switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    Image("legoLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
            }
        }
    }
    
    @ViewBuilder
    func customTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(MinifigureTab.allCases, id: \.rawValue) { tab in
                HStack(spacing: 10) {
                    Image(systemName: tab.systemImage)
                    
                    Text(tab.rawValue)
                        .font(.callout)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .containerShape(.capsule)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selectedtab = tab
                    }
                }
            }
        }
        .tabMask2(tabProgress)
        .background {
            GeometryReader {
                let size = $0.size
                let capusleWidth = size.width / CGFloat(MinifigureTab.allCases.count)
                
                Capsule()
                    .fill(scheme == .dark ? .black : .white)
                    .frame(width: capusleWidth)
                    .offset(x: tabProgress * (size.width - capusleWidth))
            }
        }
        .background(.gray.opacity(0.1), in: .capsule)
        .padding(.horizontal, 15)
    }
}


