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
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(.systemBackground))
//        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            viewModel.getDetailAboutSpecificPart(partNumber: legoPart.partNumber ?? "No part Number")
            viewModel.getLegoPartsColor(part: legoPart.partNumber ?? "No part Number")
        }
    }
    
    
    private var partHeader: some View {
        VStack(alignment: .center, spacing: 15) {
            if let legoPart = viewModel.legoPart {
                partHeaderMoc(
                    partNumber: legoPart.partNum,
                    partName: legoPart.name,
                    partColorId: legoPart.partCatId ?? 0,
                    partImage: legoPart.partImageUrl,
                    yearFrom: legoPart.yaerFrom,
                    yearTo: legoPart.yearTo)
            }
        }
        .onSubmit {
            viewModel.getDetailAboutSpecificPart(partNumber: legoPart.partNumber ?? "No part Number")
        }
    }
    
    private var displayPart: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 16) {
                if let part = viewModel.partColor {
                    ForEach(part, id: \.colorID) { partColor in
                        partColorMoc(
                            name: partColor.colorName,
                            numberOf: partColor.numberOfSet,
                            numberOfset: partColor.numberOfSetParts,
                            image: partColor.partImageUrL)
                    }
                }
            }
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
        HStack(spacing: 10) {
            displayView(url: url)
                .frame(width: 112, height: 112)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
               
                HStack(spacing: 16) {
                    StatView(
                        value: "Number of sets it in \(set)",
                        label: "sets",
                        icon: "folder.badge.plus",
                        color: .red
                    )
                    
                    StatView(
                        value: "Number of set parts \(part)",
                        label: "part",
                        icon: "tray.and.arrow.up",
                        color: .green
                    )
                    
//                    HStack(spacing: 5) {
//                        Text("Number of sets it in \(set)")
//                            .font(.caption)
//                        
//                        Text("Number of set parts \(part)")
//                            .font(.caption)
//                    }
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
    
    private func partHeaderMoc(
        partNumber: String,
        partName: String,
        partColorId: Int,
        partImage url: String?,
        yearFrom: Int?,
        yearTo: Int?
    ) -> some View {
        VStack(alignment: .center, spacing: 15) {
            displayView(url: url)
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 15) {
                Text("part number \(partNumber) \(partName) color Id \(partColorId)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .padding(8)
                
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(" Year from \(yearFrom ?? 0000 ) to \(yearTo ?? 0000)")
                    }
                    
//                    HStack(spacing: 4) {
//                        Image(systemName: "cube.box")
//                            .font(.caption)
////                        Text("\(legoParts.molds)")
//                    }
                }
            }
        }
        .background()
//        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: false)
    }
    
    private func displayView(url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "unkown")) { phase in
            switch  phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    Image(systemName: "x-mark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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


