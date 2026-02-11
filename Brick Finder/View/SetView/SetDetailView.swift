//
//  SetDetillView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/28/25.
//

import SwiftUI

struct SetDetailView: View {
    var legoSet: LegoSet.SetResults
    
    
    @StateObject var viewModel: SetVM
    @StateObject var inventoryVM: InventoryPartsVM
    
    @State private var isPressed = true
    
    @State private var selectedtab: Tab?
    @State private var tabProgress: CGFloat = 0
    @State private var dataLoadingTask: Task<Void, Never>? = nil
    
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        VStack(spacing: 0) {
            setheader
            
            customTabBar()
                .padding(.vertical, 18)
            
            setdetailList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
    
    var setheader: some View {
        VStack(alignment: .center, spacing: 15) {
            ZStack {
                displayUrlImage(url: legoSet.setImageURL ?? "Unknown")
                .frame(width: 350, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(legoSet.setNumber ?? "No set number")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text(legoSet.name ?? "no name")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("\(legoSet.year ?? 0000)")
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "cube.box")
                            .font(.caption)
                        Text("\(legoSet.numberOfParts ?? 0) pieces")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
            }
        }
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: false)
    }
    
    private var setdetailList: some View {
        VStack(spacing: 16) {
            GeometryReader {
                let size = $0.size
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        deteilDisplay
                            .id(Tab.deteils)
                            .containerRelativeFrame(.horizontal)
                        
                        minifigureDisplay
                            .id(Tab.minifigs)
                            .containerRelativeFrame(.horizontal)
                        
                        setPartDisplay
                            .id(Tab.parts)
                            .containerRelativeFrame(.horizontal)
                        
                        mocsDisplay
                            .id(Tab.mocs)
                            .containerRelativeFrame(.horizontal)
                    }
                    .scrollTargetLayout()
                    .offsetX { value in
                        let progress = -value / (size.width * CGFloat(Tab.allCases.count - 1))
                        
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
            inventoryVM.getInventoryPart(with: legoSet.setNumber ?? "No set number")
            inventoryVM.getInventoryMinifigerInSet(with: legoSet.setNumber ?? "No set number")
            viewModel.getAlternateBuilds(with: legoSet.setNumber ?? "No set number")
            viewModel.getSetInfo(with: legoSet.setNumber ?? "No set number")
        }
    }
    
    private var setPartDisplay: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), content:  {
                if let parts = inventoryVM.setInventoryPart {
                    ForEach(parts, id: \.id) { legoPart in
                        partCard(
                            image: legoPart.part.partImageURL,
                            part: legoPart.part.partNumber,
                            set: legoPart.quantity)
                    }
                    .onSubmit {
                        inventoryVM.getInventoryPart(with: legoSet.setNumber ?? "no number")
                    }
                }
            })
            .padding(15)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .mask {
            Rectangle()
                .padding(.bottom, -100)
        }
    }
    
    private var minifigureDisplay: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2), content:  {
                if let minifigures = inventoryVM.getInventoryMinifiger {
                    ForEach(minifigures, id: \.setNum) { legoMinfigures in
                        minifigCard(
                            image: legoMinfigures.setImageURL,
                            part: legoMinfigures.setNum
                        )
                    }
                    .onSubmit {
                        inventoryVM.getInventoryMinifigerInSet(with: legoSet.setNumber ?? "No set number")
                    }
                }
            })
            .padding(15)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .mask {
            Rectangle()
                .padding(.bottom, -100)
        }
    }
    
    private var mocsDisplay: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 16) {
                if let mocs = viewModel.legoSetMOCS {
                    ForEach(mocs, id: \.setNumber) { alternateBuilds in
                        mocsCard(
                            name: alternateBuilds.name,
                            creator: alternateBuilds.designerName,
                            year: alternateBuilds.year,
                            set: alternateBuilds.setNumber,
                            moc: alternateBuilds.mocImageUrl,
                            numberOf: alternateBuilds.numberOfPart)
                    }
                    .onSubmit {
                        viewModel.getAlternateBuilds(with: legoSet.setNumber ?? "no set number")
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
    }
    
    private var deteilDisplay: some View {
        ScrollView(.vertical) {
            if let details = viewModel.setInfo {
                ForEach(details, id: \.setID) { setDeteils in
                    detailCardView(
                        number: setDeteils.number ?? "No set number",
                        name: setDeteils.name ?? "no name",
                        year: setDeteils.year,
                        theme: setDeteils.theme ?? "no theme yet",
                        ThemeGroup: setDeteils.themeGroup ?? "no theme group",
                        category: setDeteils.category ?? "no category",
                        subTheme: setDeteils.subTheme ?? "no sub theme",
                        pleces: setDeteils.pleces,
                        minifigs: setDeteils.minifigs ?? 0,
                        rating: setDeteils.rating ?? 0.0,
                        availability: setDeteils.availability,
                        instructionsCount: setDeteils.instructionsCount ?? 0,
                        tags: setDeteils.extendedData?.tags ?? [],
                        description: setDeteils.extendedData?.description ?? "",
                        setImageURL: setDeteils.image?.imageURL ?? "no url",
                        retailPrice: setDeteils.legoCom?.usa.retailPrice ?? 0.0)
                }
                .onSubmit {
                    viewModel.getSetInfo(with: legoSet.setNumber ?? "no set number error")
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .mask {
            Rectangle()
                .padding(.bottom, -100)
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
    
    private func minifigCard(image url: String?, part num: String?) -> some View {
        VStack {
            displayUrlImage(url: url)
                .frame(width: 100, height: 100)
                .padding()
                
            VStack(spacing: 8) {
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
    
    private func mocsCard(name: String?, creator: String?, year: Int?, set number: String?, moc url: String?, numberOf part: Int?) -> some View {
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
                        
                        HStack(spacing: 6) {
                            Text("Created by \(creator ?? "No Name yet")")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.red)
                        }
                    }
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    StatView(
                        value: "\(part ?? 0)",
                        label: "pleces",
                        icon: "cube.box",
                        color: .green)
                    
                    StatView(
                        value: "\(year ?? 0000)",
                        label: "year",
                        icon: "calendar",
                        color: .orange)
                }
                
                HStack {
                    Text("\(part ?? 0) pleces (\(year ?? 0))")
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
    
    private func detailCardView(
        number: String,
        name: String,
        year: Int,
        theme: String,
        ThemeGroup: String,
        category: String,
        subTheme: String,
        pleces: Int,
        minifigs: Int,
        rating: Double,
        availability: String,
        instructionsCount: Int,
        tags: [String],
        description: String,
        setImageURL: String,
        retailPrice: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top image + basic info
            HStack(alignment: .top, spacing: 16) {
                displayUrlImage(url: setImageURL)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        VStack {
                            HStack {
                                Text(number)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                Spacer()
                            }
                            Spacer()
                            HStack {
                                Text(availability)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.85))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                Spacer()
                            }
                        }
                        .padding(8)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text("Released \(year)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(theme)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                        
                        HStack(spacing: 8) {
                            Text(ThemeGroup)
                            Text(category)
                            Text(subTheme)
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    }
                }
            }
            
            // Core stats
            HStack(spacing: 12) {
                StatView(
                    value: "\(pleces)",
                    label: "Pieces",
                    icon: "cube.box",
                    color: .orange
                )
                
                StatView(
                    value: "\(minifigs)",
                    label: "Minifigs",
                    icon: "person.3.fill",
                    color: .purple
                )
                
                StatView(
                    value: String(format: "%.1f", rating),
                    label: "Rating",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatView(
                    value: String(format: "$%.2f", retailPrice),
                    label: "Retail",
                    icon: "dollarsign.circle",
                    color: .green
                )
            }
            .font(.caption)
            
            // Instructions count
            if instructionsCount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "doc.richtext")
                        .foregroundColor(.blue)
                    Text("\(instructionsCount) building instruction\(instructionsCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Tags
            if !tags.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tags")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color(.systemGray6))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            
            // Description
            if !description.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(description)
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
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
    func sampleView(_ color: Color) -> some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2), content: {
                ForEach(1...10, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color.gradient)
                        .frame(height: 150)
                        .overlay {
                            VStack(alignment: .leading) {
                                Circle()
                                    .fill(.white.opacity(0.25))
                                    .frame(width: 50, height: 50)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(.white.opacity(0.25))
                                        .frame(width: 80, height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(.white.opacity(0.25))
                                        .frame(width: 60, height: 8)
                                }
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.white.opacity(0.25))
                                    .frame(width: 40, height: 8)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                }
            })
            .padding(15)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .mask {
            Rectangle()
                .padding(.bottom, -100)
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
