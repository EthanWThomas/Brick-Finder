//
//  ThemeFilterView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/24/25.
//

import SwiftUI

struct ThemeFilterView: View {
    var hint: String
    var options: [String]
    var anchor: Anchor = .bottom
    var maxWidth: CGFloat = 150
    var cornerRadius: CGFloat = 15
    
    @Binding var selection: String?
    // View Properies
    
    @State private var showOption: Bool = false
    // Environment scheme
    
    @Environment(\.colorScheme) private var scheme
    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State private var zIndex: Double = 1000.0
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack(spacing: 0) {
                if showOption && anchor == .top {
                    optionsView()
                }
                
                HStack(spacing: 0) {
                    Text(selection ?? hint)
                        .foregroundStyle(selection == nil ? .gray : .primary)
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: "chevron.down")
                        .font(.title3)
                        .foregroundStyle(.gray)
                        // Rotating Icon
                        .rotationEffect(.init(degrees: showOption ? -180 : 0))
                }
                .padding(.horizontal, 15)
                .frame(width: size.width, height: size.height)
                .background(scheme == .dark ? .black : .white)
                .contentShape(.rect)
                .onTapGesture {
                    index += 1
                    zIndex = index
                    withAnimation(.snappy) {
                        showOption.toggle()
                    }
                }
               
                
                if showOption && anchor == .bottom {
                    optionsView()
                }
            }
            .clipped()
            // Clips All Interaction within its's bounds
            .contentShape(.rect)
            .background((scheme == .dark ? Color.black :
                            Color.white).shadow(.drop(color: .primary.opacity(0.15), radius: 4)), in: .rect(cornerRadius: cornerRadius))
            .frame(height: size.height, alignment: anchor == .top ? .bottom : .top)
        }
        .frame(width: maxWidth, height: 40)
//        .zIndex(1000)
    }
    
    // Options View
    @ViewBuilder
    func optionsView() -> some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(options, id: \.self) { opiton in
                    HStack(spacing: 0) {
                        Text(opiton)
                            .lineLimit(1)
                        
                        Spacer(minLength: 0)
                        
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .opacity(selection == opiton ? 1 : 0)
                    }
                    .foregroundStyle(selection == opiton ? Color.primary : Color.gray)
                    .animation(.none, value: selection)
                    .frame(height: 40)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            selection = opiton
                            // Closing Drop Down view
                            showOption = false
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            // Adding transition
            .transition(.move(edge: anchor == .top ? .bottom : .top))
            
        }
        .frame(width: 150, height: 200) // Match the width of the button and give it a max height
        .cornerRadius(15)
        .shadow(radius: 5)
//        .offset(y: 100) // Adjust this to position it under the button
        .zIndex(200) // Ensure it's on top of everything
    }
    
    enum Anchor {
        case top
        case bottom
    }
}


#Preview {
//    ThemeFilterView(selection: "", scheme: <#T##arg#>, cornerRadius: <#T##CGFloat#>, maxWidth: <#T##CGFloat#>)
}
