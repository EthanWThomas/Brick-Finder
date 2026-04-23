//
//  SavedMinifigureDetailView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 4/23/26.
//

import SwiftUI
import SwiftData

struct SavedMinifigureDetailView: View {
    let minifigure: LegoDataModel
    
    @StateObject var minifigureInSetTheyCameIn: MiniFiguresDetailVM
    @StateObject var partVM: PartVM
    
    @State private var isPressed = true
    
    @State private var selectedtab: MinifigureTab?
    @State private var tabProgress: CGFloat = 0
    @State private var dataLoadingTask: Task<Void, Never>? = nil
    
    @Environment(\.colorScheme) private var scheme
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack(spacing: 0) {
            heroSelection
            
            customTabBar()
                .padding(.vertical, 18)
            
            minifiguresList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private var heroSelection: some View {
        VStack(spacing: 0) {
            // Background header with gradient
            ZStack(alignment: .bottom) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.2),
                        Color(.systemBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                
                // Minifigure image
                VStack {
                    displayUrlImage(url: minifigure.setImageUrl)
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                }
                .offset(y: 30)
            }
            .padding(.bottom, 30)
            
            // Name and set number section
            VStack(spacing: 8) {
                Text(minifigure.name ?? "Not Found")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal)
                
                HStack(spacing: 8) {
                    Image(systemName: "number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(minifigure.setNum ?? "Not Found")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 16)
        }
    }
    
    private var minifiguresList: some View {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6).opacity(0.3))
        .onAppear {
            partVM.getminifigePart(figNumber: minifigure.setNum ?? "Not Found")
            minifigureInSetTheyCameIn.getMinifigInSetCameIn(figNumber: minifigure.setNum ?? "Not Found")
        }
    }
    
    private var partSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Minifigure Parts")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let parts = partVM.inventoryPart, !parts.isEmpty {
                        Text("\(parts.count) part\(parts.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                .padding(.top, 8)
                
                // Parts grid
                if partVM.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else if let parts = partVM.inventoryPart, !parts.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 16) {
                        ForEach(parts, id: \.id) { part in
                            partCard(
                                image: part.part.partImageURL,
                                part: part.part.partNumber,
                                set: part.quantity)
                        }
                    }
                    .padding(.horizontal, 15)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "cube.box")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No parts found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
            .padding(.bottom, 20)
            .onSubmit {
                partVM.getminifigePart(figNumber: minifigure.setNum ?? "Not Found")
            }
        }
    }
    
    private var setsSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sets This Minifigure Appears In")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let sets = minifigureInSetTheyCameIn.minifigInSet, !sets.isEmpty {
                        Text("\(sets.count) set\(sets.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                .padding(.top, 8)
                
                // Sets list
                if minifigureInSetTheyCameIn.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else if let minifigInSetCameIn = minifigureInSetTheyCameIn.minifigInSet, !minifigInSetCameIn.isEmpty {
                    LazyVStack(spacing: 16) {
                        ForEach(minifigInSetCameIn, id: \.setNum) { legoSet in
                            setItCameInCard(
                                name: legoSet.name,
                                set: legoSet.setNum,
                                setUrl: legoSet.setImageURL,
                                numberOf: legoSet.numberOfPart)
                        }
                    }
                    .padding(.horizontal, 15)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "folder")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No sets found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
            .padding(.bottom, 20)
            .onSubmit {
                minifigureInSetTheyCameIn.getMinifigInSetCameIn(figNumber: minifigure.setNum ?? "Not Found")
            }
        }
    }
    
    private func partCard(image url: String?, part num: String?, set quantity: Int) -> some View {
        VStack(spacing: 12) {
            // Part image
            displayUrlImage(url: url)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.top, 8)
            
            // Quantity badge
            HStack(spacing: 4) {
                Text("\(quantity.formatted(.number))")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("×")
                    .font(.subheadline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color.blue)
            )
            
            // Part number
            Text(num ?? "no number")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func setItCameInCard(name: String?, set number: String?, setUrl url: String?, numberOf part: Int?) -> some View {
        HStack(spacing: 16) {
            // Set image
            displayUrlImage(url: url)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    ZStack {
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        VStack {
                            Spacer()
                            HStack {
                                Text(number ?? "N/A")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                Spacer()
                            }
                        }
                        .padding(10)
                    }
                )
            
            // Set info
            VStack(alignment: .leading, spacing: 10) {
                // Set name
                Text(name ?? "No Name")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Pieces stat
                if let partCount = part, partCount > 0 {
                    HStack(spacing: 8) {
                        StatView(
                            value: "\(partCount)",
                            label: "Pieces",
                            icon: "cube.box",
                            color: .green)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
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
                    Image("legoRedBrick")
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
