//
//  PartDetailsView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 9/30/25.
//

import SwiftUI

struct PartDetailsView: View {
    @StateObject var viewModel: PartVM
    
    var legoPart: AllParts.PartResults
//    var colorCombinations: ColorCombination
    
    @State private var isPressed = true
    
    @State private var selectedtab: Tab?
    @State private var tabProgress: CGFloat = 0
    
    @Environment(\.colorScheme) private var scheme
   
    var body: some View {
        VStack(spacing: 0) {
            partHeader
            
            displayPart
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.getDetailAboutSpecificPart(partNumber: legoPart.partNumber ?? "No part Number")
            viewModel.getLegoPartsColor(part: legoPart.partNumber ?? "No part Number")
            
        }
    }
    
 
    
    
    private var partHeader: some View {
        VStack(alignment: .center, spacing: 0) {
            if viewModel.isLoading && viewModel.legoPart == nil {
                ProgressView()
                    .frame(height: 200)
            } else if let legoPart = viewModel.legoPart {
                partHeaderMoc(
                    partNumber: legoPart.partNum,
                    partName: legoPart.name,
                    partColorId: legoPart.partCatId ?? 0,
                    partImage: legoPart.partImageUrl,
                    yearFrom: legoPart.yaerFrom,
                    yearTo: legoPart.yearTo)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "cube.box")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Part not found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            }
        }
        .onSubmit {
            viewModel.getDetailAboutSpecificPart(partNumber: legoPart.partNumber ?? "No part Number")
        }
    }
    
    private var displayPart: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                if let part = viewModel.partColor, !part.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Available Colors")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("\(part.count) color\(part.count == 1 ? "" : "s") available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    .padding(.top, 8)
                }
                
                // Color list
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else if let part = viewModel.partColor, !part.isEmpty {
                    LazyVStack(spacing: 16) {
                        ForEach(part, id: \.colorID) { partColor in
                            partColorMoc(
                                name: partColor.colorName,
                                numberOf: partColor.numberOfSet,
                                numberOfset: partColor.numberOfSetParts,
                                image: partColor.partImageUrL)
                        }
                    }
                    .padding(.horizontal, 15)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "paintpalette")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No colors found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
            .padding(.bottom, 20)
            .onSubmit {
                viewModel.getLegoPartsColor(part: legoPart.partNumber ?? "Unknown")
            }
        }
    }
    
    private func partColorMoc(
        name: String,
        numberOf set: Int,
        numberOfset part: Int,
        image url: String?
    ) -> some View {
        HStack(spacing: 16) {
            // Color image
            displayView(url: url)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
            
            // Color info
            VStack(alignment: .leading, spacing: 12) {
                // Color name
                Text(name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Stats
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "folder.badge.plus")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(set)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("Sets")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "tray.and.arrow.up")
                            .font(.caption)
                            .foregroundColor(.green)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(part)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("Set Parts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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
    
    private func partHeaderMoc(
        partNumber: String,
        partName: String,
        partColorId: Int,
        partImage url: String?,
        yearFrom: Int?,
        yearTo: Int?
    ) -> some View {
        VStack(spacing: 0) {
            // Background header with gradient
            ZStack(alignment: .bottom) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.orange.opacity(0.3),
                        Color.red.opacity(0.2),
                        Color(.systemBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
                
                // Part image
                VStack {
                    displayView(url: url)
                        .frame(width: 160, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                }
                .offset(y: 20)
            }
            .padding(.bottom, 20)
            
            // Part info section
            VStack(spacing: 12) {
                // Part name
                Text(partName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal)
                
                // Part number badge
                HStack(spacing: 8) {
                    Image(systemName: "number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(partNumber)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                
                // Color ID badge
                HStack(spacing: 6) {
                    Image(systemName: "paintpalette.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Color ID: \(partColorId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                
                // Year range
                if let yearFrom = yearFrom, let yearTo = yearTo, yearFrom > 0, yearTo > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(yearFrom) - \(yearTo)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
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
    
    private func displayView(url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "unknown")) { phase in
            switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    Image(systemName: "cube.box")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    func customTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
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
        .tabMask(tabProgress)
        .background {
            GeometryReader {
                let size = $0.size
                let capusleWidth = size.width / CGFloat(Tab.allCases.count)
                
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


