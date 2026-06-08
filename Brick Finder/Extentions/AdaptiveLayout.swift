//
//  AdaptiveLayout.swift
//  Brick Finder
//
//  Shared adaptive layout conventions so every primary screen reacts to the
//  horizontal size class consistently (iPhone/compact vs iPad/regular) instead
//  of scattering magic numbers across views.
//

import SwiftUI

enum AdaptiveLayout {
    /// Card grid that yields two columns in compact width and scales to more
    /// columns on regular-width (iPad) layouts without letting cards stretch.
    static func cardColumns(minimum: CGFloat = 165, maximum: CGFloat = 260, spacing: CGFloat = 16) -> [GridItem] {
        [GridItem(.adaptive(minimum: minimum, maximum: maximum), spacing: spacing)]
    }

    /// Horizontal content inset that grows on regular-width layouts.
    static func horizontalPadding(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 24 : 16
    }

    /// Readable content widths that stop primary content from stretching
    /// edge-to-edge on wide iPad layouts.
    enum ContentWidth {
        static let standard: CGFloat = 760
        static let detail: CGFloat = 820
        static let wide: CGFloat = 900
    }
}

extension View {
    /// Constrains content to `maxWidth` and centers it on regular-width
    /// layouts, while leaving compact-width (iPhone) layouts untouched.
    @ViewBuilder
    func adaptiveReadableWidth(_ maxWidth: CGFloat, sizeClass: UserInterfaceSizeClass?) -> some View {
        if sizeClass == .regular {
            frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity)
        } else {
            self
        }
    }
}
