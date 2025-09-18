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
    
    @State private var selectedtab: Tab?
    @State private var tabProgress: CGFloat = 0
    @State private var dataLoadingTask: Task<Void, Never>? = nil
    
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        VStack(spacing: 0) {
            setheader
            
            customTabBar()
                .padding(.vertical, 18)
            
            setdetaillist
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
    
    var setheader: some View {
        VStack(alignment: .center, spacing: 15) {
            ZStack {
                displayUrlImage(url: legoSet.setImageURL ?? "Unknown")
                .frame(width: 250, height: 250)
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
    
    private var setdetaillist: some View {
        VStack(spacing: 16) {
            GeometryReader {
                let size = $0.size
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
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
        }
    }
    
    private var setPartDisplay: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), content:  {
                if let parts = inventoryVM.setInventoryPart {
                    ForEach(parts, id: \.id) { legoPart in
                        partCard(image: legoPart.part.partImageURL, part: legoPart.part.partNumber, set: legoPart.quantity)
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
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), content: {
                if let mocs = viewModel.legoSetMOCS {
                    ForEach(mocs, id: \.setNumber) { alternateBuilds in
                        mocsCard(
                            name: alternateBuilds.name,
                            year: alternateBuilds.year,
                            set: alternateBuilds.setNumber,
                            moc: alternateBuilds.mocImageUrl,
                            numberOf: alternateBuilds.numberOfPart)
                    }
                    .onSubmit {
                        viewModel.getAlternateBuilds(with: legoSet.setNumber ?? "no set number")
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
    
    private func mocsCard(name: String?, year: Int?, set number: String?, moc url: String?, numberOf part: Int?) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                displayUrlImage(url: url)
                    .frame(height: 180)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(number ?? "No set number")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .padding(8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(name ?? "No set name")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text("\(year ?? 0)")
                                .font(.caption)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "cube.box")
                                .font(.caption)
                            Text("\(part ?? 0) pieces")
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(Color(.secondaryLabel))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
//            ZStack(alignment: .topTrailing) {
//                displayUrlImage(url: url)
//                    .frame(height: 180)
//                    .aspectRatio(contentMode: .fit)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                
//                Text(number ?? "No set number")
//                    .font(.caption)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(Color.blue)
//                    .clipShape(Capsule())
//                    .padding(8)
//                
//                VStack(alignment: .leading, spacing: 12) {
//                    Text(name ?? "No set name")
//                        .font(.headline)
//                        .fontWeight(.bold)
//                        .foregroundColor(.primary)
//                    
//                    HStack(spacing: 16) {
//                        HStack(spacing: 4) {
//                            Image(systemName: "calendar")
//                                .font(.caption)
//                            Text("\(year ?? 0)")
//                                .font(.caption)
//                        }
//                        
//                        HStack(spacing: 4) {
//                            Image(systemName: "cube.box")
//                                .font(.caption)
//                            Text("\(part ?? 0) pieces")
//                                .font(.caption)
//                        }
//                    }
//                    .foregroundStyle(Color(.secondaryLabel))
//                }
//                .padding(.horizontal, 16)
//                .padding(.bottom, 16)
//            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: false)
        .frame(height: 210)
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
    
//    private func displayPartUrlImage(url: String?) -> some View {
//        AsyncImage(url: URL(string: url ?? "Unknown")) { phase in
//            switch phase {
//                case .empty:
//                    ProgressView()
//                case .success(let image):
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 80, height: 80)
//                default:
//                    Image("legoLogo")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 80, height: 80)
//            }
//        }
//    }
    
//    private func displayMinifgureUrlImage(url: String?) -> some View {
//        AsyncImage(url: URL(string: url ?? "Unknown")) { phase in
//            switch phase {
//                case .empty:
//                    ProgressView()
//                case .success(let image):
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 100, height: 100)
//                default:
//                    Image("legoLogo")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 100, height: 100)
//            }
//        }
//    }
    
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


/**
 import SwiftUI

 struct MinifigureDetailView: View {
     let minifigureData = MinifigureData(
         name: "Police Officer",
         id: "cty0001",
         year: 2014,
         theme: "City",
         subtheme: "Police",
         rating: 4.8,
         totalSets: 12,
         description: "Friendly police officer ready to keep LEGO City safe and sound!"
     )
     
     let parts = [
         PartData(name: "Police Cap", image: "part-police-cap", partNumber: "3624pb01"),
         PartData(name: "Head with Smile", image: "part-police-head", partNumber: "3626cpb0001"),
         PartData(name: "Police Torso", image: "part-police-torso", partNumber: "973pb0001c01"),
         PartData(name: "Blue Legs", image: "part-police-legs", partNumber: "970c00pb001")
     ]
     
     let sets = [
         SetData(name: "Police Station", setNumber: "60047", year: 2014, pieces: 854, theme: "City", image: "set-police-station"),
         SetData(name: "Police Chase", setNumber: "60128", year: 2016, pieces: 318, theme: "City", image: "set-police-chase"),
         SetData(name: "Police Helicopter", setNumber: "60067", year: 2015, pieces: 259, theme: "City", image: "set-police-helicopter")
     ]
     
     var body: some View {
         ScrollView {
             VStack(spacing: 0) {
                 // Hero Section
                 heroSection
                 
                 // Parts Section
                 partsSection
                 
                 // Sets Section
                 setsSection
             }
         }
         .background(Color(.systemBackground))
         .ignoresSafeArea(edges: .top)
     }
     
     private var heroSection: some View {
         ZStack {
             // Gradient Background
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
                     // Left side - Text content
                     VStack(alignment: .leading, spacing: 16) {
                         // Badge
                         HStack {
                             Text("\(minifigureData.theme) • \(minifigureData.year)")
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
                         
                         // Title
                         Text(minifigureData.name)
                             .font(.system(size: 48, weight: .bold))
                             .foregroundColor(.white)
                             .multilineTextAlignment(.leading)
                         
                         // Description
                         Text(minifigureData.description)
                             .font(.title3)
                             .foregroundColor(.white.opacity(0.9))
                             .multilineTextAlignment(.leading)
                         
                         // Stats
                         HStack(spacing: 16) {
                             StatsBadge(icon: "calendar", text: "\(minifigureData.year)")
                             StatsBadge(icon: "cube.box", text: "\(minifigureData.totalSets) Sets")
                             StatsBadge(icon: "star.fill", text: "\(minifigureData.rating, specifier: "%.1f")")
                         }
                         
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
                     
                     // Right side - Minifigure image
                     VStack {
                         Image("minifigure-police")
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 320, height: 384)
                             .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                             .scaleEffect(1.02)
                             .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: true)
                     }
                 }
                 .padding(.horizontal, 32)
             }
             .padding(.vertical, 48)
         }
         .frame(minHeight: 500)
     }
     
     private var partsSection: some View {
         VStack(spacing: 32) {
             Text("Minifigure Parts")
                 .font(.largeTitle)
                 .fontWeight(.bold)
                 .foregroundColor(.primary)
             
             LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 24) {
                 ForEach(parts, id: \.partNumber) { part in
                     PartCard(part: part)
                 }
             }
             .padding(.horizontal, 32)
         }
         .padding(.vertical, 48)
     }
     
     private var setsSection: some View {
         VStack(spacing: 32) {
             VStack(spacing: 16) {
                 Text("Appears in \(sets.count) Sets")
                     .font(.largeTitle)
                     .fontWeight(.bold)
                     .foregroundColor(.primary)
                 
                 Text("Discover all the amazing LEGO sets featuring this minifigure")
                     .font(.title3)
                     .foregroundColor(.secondary)
                     .multilineTextAlignment(.center)
             }
             
             LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 24) {
                 ForEach(sets, id: \.setNumber) { set in
                     SetCard(set: set)
                 }
             }
             .padding(.horizontal, 32)
         }
         .padding(.vertical, 48)
         .background(Color(.systemGray6).opacity(0.5))
     }
 }

 struct StatsBadge: View {
     let icon: String
     let text: String
     
     var body: some View {
         HStack(spacing: 8) {
             Image(systemName: icon)
                 .font(.caption)
             Text(text)
                 .font(.caption)
                 .fontWeight(.medium)
         }
         .foregroundColor(.white)
         .padding(.horizontal, 16)
         .padding(.vertical, 8)
         .background(Color.white.opacity(0.2))
         .clipShape(Capsule())
     }
 }

 struct PartCard: View {
     let part: PartData
     
     var body: some View {
         VStack(spacing: 16) {
             Image(part.image)
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: 80, height: 80)
             
             VStack(spacing: 8) {
                 Text(part.name)
                     .font(.headline)
                     .fontWeight(.semibold)
                     .multilineTextAlignment(.center)
                 
                 Text(part.partNumber)
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
     }
 }

 struct SetCard: View {
     let set: SetData
     
     var body: some View {
         VStack(alignment: .leading, spacing: 16) {
             ZStack(alignment: .topTrailing) {
                 Image(set.image)
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(height: 180)
                     .clipShape(RoundedRectangle(cornerRadius: 12))
                 
                 Text(set.setNumber)
                     .font(.caption)
                     .fontWeight(.bold)
                     .foregroundColor(.white)
                     .padding(.horizontal, 8)
                     .padding(.vertical, 4)
                     .background(Color.blue)
                     .clipShape(Capsule())
                     .padding(8)
             }
             
             VStack(alignment: .leading, spacing: 12) {
                 Text(set.name)
                     .font(.headline)
                     .fontWeight(.bold)
                     .foregroundColor(.primary)
                 
                 HStack(spacing: 16) {
                     HStack(spacing: 4) {
                         Image(systemName: "calendar")
                             .font(.caption)
                         Text("\(set.year)")
                             .font(.caption)
                     }
                     
                     HStack(spacing: 4) {
                         Image(systemName: "cube.box")
                             .font(.caption)
                         Text("\(set.pieces) pieces")
                             .font(.caption)
                     }
                 }
                 .foregroundColor(.secondary)
                 
                 Text(set.theme)
                     .font(.caption)
                     .fontWeight(.medium)
                     .foregroundColor(.blue)
             }
             .padding(.horizontal, 16)
             .padding(.bottom, 16)
         }
         .background(Color.white)
         .clipShape(RoundedRectangle(cornerRadius: 16))
         .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
         .scaleEffect(1.0)
         .animation(.easeInOut(duration: 0.2), value: false)
     }
 }

 // Data Models
 struct MinifigureData {
     let name: String
     let id: String
     let year: Int
     let theme: String
     let subtheme: String
     let rating: Double
     let totalSets: Int
     let description: String
 }

 struct PartData {
     let name: String
     let image: String
     let partNumber: String
 }

 struct SetData {
     let name: String
     let setNumber: String
     let year: Int
     let pieces: Int
     let theme: String
     let image: String
 }

 #Preview {
     MinifigureDetailView()
 }

 */
