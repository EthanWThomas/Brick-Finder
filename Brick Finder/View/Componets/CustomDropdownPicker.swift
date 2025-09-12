//
//  CustomDropdownPicker.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 9/12/25.
//

import SwiftUI

struct CustomDropdownPicker: View {
    let hint: String
    let options: [LegoThemes]
    @Binding var selection: String
    @Binding var showDropdown: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDropdown.toggle()
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? hint : selection)
                        .foregroundStyle(selection.isEmpty ? .secondary: .primary)
                        .font(.system(size: 14))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(showDropdown ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: showDropdown)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                }
            }
            
            if showDropdown {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(LegoThemes.allCases, id: \.self) { option in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selection = option.rawValue
                                    showDropdown = false
                                }
                            }) {
                                HStack {
                                    Text(option.displayName)
                                        .tag(option.rawValue)
                                        .foregroundColor(.primary)
                                        .font(.system(size: 14))
                                    Spacer()
                                    if selection == option.rawValue {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 12))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(selection == option.rawValue ? Color.blue.opacity(0.1) : Color.clear)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if option.rawValue != options.last?.rawValue {
                                Divider()
                                    .padding(.horizontal, 12)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .offset(y: 4)
                    .zIndex(1000)
                }
                .frame(width: 150, height: 200) // Match the width of the button and give it a max height
                .cornerRadius(15)
                .shadow(radius: 5)
        //        .offset(y: 100) // Adjust this to position it under the button
                .zIndex(200)
            }
        }
        .frame(width: 140)
    }
}

//#Preview {
//    CustomDropdownPicker()
//}
