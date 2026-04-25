//
//  SavedSetDetailView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 4/24/26.
//

import SwiftUI
import SwiftData

struct SavedSetDetailView: View {
    var legoSet: LegoSetsDataModel
    
    @StateObject var viewModel: SetVM
    @StateObject var inventoryVM: InventoryPartsVM
    
    @State private var isPressed = true
    
    @State private var selectedtab: Tab?
    @State private var tabProgress: CGFloat = 0
    @State private var dataLoadingTask: Task<Void, Never>? = nil
    
    @Environment(\.colorScheme) private var scheme
    
    private var primarySetInfo: SetInfo.Sets? {
        viewModel.setInfo?.first
    }
    
    private var displaySetName: String {
        primarySetInfo?.name ?? legoSet.name ?? "No set name"
    }
    
    private var displaySetNumber: String {
        primarySetInfo?.number ?? legoSet.setNumber ?? "No set number"
    }
    
    private var displaySetYear: Int {
        primarySetInfo?.year ?? legoSet.year ?? 0
    }
    
    private var displaySetPieces: Int {
        primarySetInfo?.pleces ?? legoSet.numberOfParts ?? 0
    }
    
    private var displaySetImageURL: String {
        primarySetInfo?.image?.imageURL ?? legoSet.setImageURL ?? "Unknown"
    }
    
    private var displaySetTheme: String? {
        primarySetInfo?.theme
    }
    
    private var displaySetAvailability: String? {
        primarySetInfo?.availability
    }
    
    private var legoSetResults: LegoSet.SetResults {
        LegoSet.SetResults(
            setNumber: legoSet.setNumber,
            name: legoSet.name,
            year: legoSet.year,
            themeID: legoSet.themeID,
            numberOfParts: legoSet.numberOfParts,
            setImageURL: legoSet.setImageURL,
            setURL: legoSet.setURL,
            lastModifieDT: legoSet.lastModifieDT
        )
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                NavigationStack {
                    setheader
                    
                    customTabBar()
                        .padding(.vertical, 18)
                        .background(Color(.systemBackground))
                        .zIndex(1)
                    
                    setdetailList
                        .zIndex(0)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    
    var setheader: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .topLeading) {
                displayUrlImage(url: displaySetImageURL)
                    .frame(maxWidth: .infinity)
                    .frame(height: 190)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.22)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    )
                
                Text(displaySetNumber)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial.opacity(0.7))
                    .clipShape(Capsule())
                    .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(displaySetName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    setMetaPill(icon: "calendar", value: "\(displaySetYear)")
                    setMetaPill(icon: "cube.box.fill", value: "\(displaySetPieces) pieces")
                    
                    if let theme = displaySetTheme, !theme.isEmpty {
                        setMetaPill(icon: "tag.fill", value: theme)
                    }
                }
                
                if let availability = displaySetAvailability, !availability.isEmpty {
                    Text(availability)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(availabilityColor(availability).gradient)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(scheme == .dark ? Color(.systemGray6) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 15)
        .padding(.top, 8)
    }
    
    private var setdetailList: some View {
        VStack(spacing: 0) {
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
                // Keep pages from drawing under the tab bar/header area.
                .clipped()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.1))
        .task(id: legoSet.setNumber ?? "No set number") {
            await viewModel.loadSetDetail(
                setNumber: legoSet.setNumber ?? "No set number",
                inventoryVM: inventoryVM
            )
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
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .scrollIndicators(.automatic)
        .safeAreaPadding(.bottom, 8)
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
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .scrollIndicators(.automatic)
        .safeAreaPadding(.bottom, 8)
    }
    
    private var mocsDisplay: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 16) {
                if let mocs = viewModel.legoSetMOCS {
                    if mocs.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            
                            Text("This set has no MOCs")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
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
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                }
            }
            .padding(15)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .scrollIndicators(.automatic)
        .safeAreaPadding(.bottom, 8)
    }
    
    
    
    private var deteilDisplay: some View {
        ScrollView(.vertical) {
            if let details = viewModel.setInfo {
                if details.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        
                        Text("No detail for this set yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    ForEach(details, id: \.setID) { setDeteils in
                        detailCardView(
                            number: setDeteils.number ?? "No set number",
                            name: setDeteils.name ?? "no name",
                            year: setDeteils.year,
                            theme: setDeteils.theme ?? "no theme yet",
                            themeGroup: setDeteils.themeGroup ?? "no theme group",
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
                            retailPrice: setDeteils.legoCom?.usa.retailPrice ?? 0.0,
                            showHeroBlock: details.count > 1
                        )
                    }
                    .onSubmit {
                        viewModel.getSetInfo(with: legoSet.setNumber ?? "no set number error")
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            }
        }
        .scrollIndicators(.automatic)
        .safeAreaPadding(.bottom, 8)
        .padding(.top, 8)
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
                        
                        Text("Created by \(creator ?? "Unknown")")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    StatView(
                        value: "\(part ?? 0)",
                        label: "Pieces",
                        icon: "cube.box",
                        color: .green)
                    
                    StatView(
                        value: "\(year ?? 0000)",
                        label: "year",
                        icon: "calendar",
                        color: .orange)
                }
                
                HStack {
                    Text("\(part ?? 0) pieces · \(year ?? 0)")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
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
        themeGroup: String,
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
        retailPrice: Double,
        showHeroBlock: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if showHeroBlock {
                HStack(alignment: .top, spacing: 16) {
                    displayUrlImage(url: setImageURL)
                        .frame(width: 132, height: 132)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                                        .background(availabilityColor(availability).opacity(0.9))
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
                            
                            themeMetadataRows(
                                themeGroup: themeGroup,
                                category: category,
                                subTheme: subTheme
                            )
                        }
                    }
                }
            } else {
                Text("Specifications & description")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
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
                .padding(.vertical, 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Set Snapshot")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    setMetaPill(icon: "shippingbox.fill", value: releaseStatusText(isReleased: availability.lowercased() != "retired"))
                    setMetaPill(icon: "calendar.badge.clock", value: availability)
                }
            }
            
            if instructionsCount > 0 {
                VStack(alignment: .leading, spacing: 10) {
                    Label {
                        Text("\(instructionsCount) building instruction\(instructionsCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "doc.richtext")
                            .foregroundStyle(.blue)
                    }
                    instructionPage()
                }
            }
            
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
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    private func themeMetadataRows(themeGroup: String, category: String, subTheme: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if themeGroup != "no theme group", !themeGroup.isEmpty {
                Text(themeGroup)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if category != "no category", !category.isEmpty {
                Text(category)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if subTheme != "no sub theme", !subTheme.isEmpty {
                Text(subTheme)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func setMetaPill(icon: String, value: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .lineLimit(1)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
    
    private func availabilityColor(_ availability: String) -> Color {
        switch availability.lowercased() {
            case "retired":
                return .orange
            case "available":
                return .green
            default:
                return .blue
        }
    }
    
    private func releaseStatusText(isReleased: Bool) -> String {
        isReleased ? "In circulation" : "Retired"
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
                    Image("legoMinifigure")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
            }
        }
    }
    
    private func instructionPage() -> some View {
        NavigationLink {
            LegoInstructionsView(legoSet: legoSetResults, viewModel: viewModel)
        } label: {
            Text("View building instructions")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
                Button {
                    withAnimation(.snappy) {
                        selectedtab = tab
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: tab.systemImage)
                        Text(tab.rawValue)
                            .font(.callout)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
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
