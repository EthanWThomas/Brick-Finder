//
//  SearchBar.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/12/25.
//

import SwiftUI

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var searchText: String
    var onCancel: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    private let cornerRadius: CGFloat = 12
    private var accentColor: Color { Color("TabbarColor") }

    private var showsClearButton: Bool {
        isFocused || !searchText.isEmpty
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.medium))
                .foregroundStyle(magnifyingGlassColor)
                .frame(width: 20, alignment: .center)

            TextField("Search sets, parts, minifigs...", text: $searchText)
                .font(.subheadline)
                .textFieldStyle(.plain)
                .foregroundStyle(Color.primary)
                .tint(accentColor)
                .focused($isFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()

            if showsClearButton {
                clearButton
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(borderColor, lineWidth: borderWidth)
        )
        .shadow(
            color: shadowColor,
            radius: shadowRadius,
            x: 0,
            y: shadowY
        )
        .animation(.easeInOut(duration: 0.22), value: isFocused)
        .animation(.easeInOut(duration: 0.18), value: showsClearButton)
    }

    private var clearButton: some View {
        Button(action: cancelSearch) {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color(.systemGray3))
        }
        .buttonStyle(.plain)
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
        .accessibilityLabel("Clear search")
    }

    private var magnifyingGlassColor: Color {
        if isFocused { return accentColor }
        return searchText.isEmpty ? Color.secondary : Color.primary
    }

    private var borderColor: Color {
        isFocused ? accentColor : Color(.systemGray4)
    }

    private var borderWidth: CGFloat {
        isFocused ? 1.5 : 1
    }

    private var shadowColor: Color {
        isFocused ? accentColor.opacity(0.18) : Color.black.opacity(0.08)
    }

    private var shadowRadius: CGFloat {
        isFocused ? 8 : 4
    }

    private var shadowY: CGFloat {
        isFocused ? 3 : 2
    }

    private func cancelSearch() {
        searchText = ""
        isFocused = false
        onCancel?()
    }
}

//#Preview {
//    SearchBar(searchText: .constant(""))
//}
