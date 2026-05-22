import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "TabbarColor" asset catalog color resource.
    static let tabbar = DeveloperToolsSupport.ColorResource(name: "TabbarColor", bundle: resourceBundle)

    /// The "mainBackgroundColor" asset catalog color resource.
    static let mainBackground = DeveloperToolsSupport.ColorResource(name: "mainBackgroundColor", bundle: resourceBundle)

    /// The "mainBackgroundColor2" asset catalog color resource.
    static let mainBackgroundColor2 = DeveloperToolsSupport.ColorResource(name: "mainBackgroundColor2", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "Gemini_Generated_Image_7vf8eq7vf8eq7vf8" asset catalog image resource.
    static let geminiGeneratedImage7Vf8Eq7Vf8Eq7Vf8 = DeveloperToolsSupport.ImageResource(name: "Gemini_Generated_Image_7vf8eq7vf8eq7vf8", bundle: resourceBundle)

    /// The "RedLegoBrick" asset catalog image resource.
    static let redLegoBrick = DeveloperToolsSupport.ImageResource(name: "RedLegoBrick", bundle: resourceBundle)

    /// The "legoMinifigure" asset catalog image resource.
    static let legoMinifigure = DeveloperToolsSupport.ImageResource(name: "legoMinifigure", bundle: resourceBundle)

    /// The "legoRedBrick" asset catalog image resource.
    static let legoRedBrick = DeveloperToolsSupport.ImageResource(name: "legoRedBrick", bundle: resourceBundle)

    /// The "minifigure" asset catalog image resource.
    static let minifigure = DeveloperToolsSupport.ImageResource(name: "minifigure", bundle: resourceBundle)

    /// The "setImage" asset catalog image resource.
    static let set = DeveloperToolsSupport.ImageResource(name: "setImage", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "TabbarColor" asset catalog color.
    static var tabbar: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbar)
#else
        .init()
#endif
    }

    /// The "mainBackgroundColor" asset catalog color.
    static var mainBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainBackground)
#else
        .init()
#endif
    }

    /// The "mainBackgroundColor2" asset catalog color.
    static var mainBackgroundColor2: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainBackgroundColor2)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "TabbarColor" asset catalog color.
    static var tabbar: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .tabbar)
#else
        .init()
#endif
    }

    /// The "mainBackgroundColor" asset catalog color.
    static var mainBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .mainBackground)
#else
        .init()
#endif
    }

    /// The "mainBackgroundColor2" asset catalog color.
    static var mainBackgroundColor2: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .mainBackgroundColor2)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "TabbarColor" asset catalog color.
    static var tabbar: SwiftUI.Color { .init(.tabbar) }

    /// The "mainBackgroundColor" asset catalog color.
    static var mainBackground: SwiftUI.Color { .init(.mainBackground) }

    /// The "mainBackgroundColor2" asset catalog color.
    static var mainBackgroundColor2: SwiftUI.Color { .init(.mainBackgroundColor2) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "TabbarColor" asset catalog color.
    static var tabbar: SwiftUI.Color { .init(.tabbar) }

    /// The "mainBackgroundColor" asset catalog color.
    static var mainBackground: SwiftUI.Color { .init(.mainBackground) }

    /// The "mainBackgroundColor2" asset catalog color.
    static var mainBackgroundColor2: SwiftUI.Color { .init(.mainBackgroundColor2) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "Gemini_Generated_Image_7vf8eq7vf8eq7vf8" asset catalog image.
    static var geminiGeneratedImage7Vf8Eq7Vf8Eq7Vf8: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .geminiGeneratedImage7Vf8Eq7Vf8Eq7Vf8)
#else
        .init()
#endif
    }

    /// The "RedLegoBrick" asset catalog image.
    static var redLegoBrick: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .redLegoBrick)
#else
        .init()
#endif
    }

    /// The "legoMinifigure" asset catalog image.
    static var legoMinifigure: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .legoMinifigure)
#else
        .init()
#endif
    }

    /// The "legoRedBrick" asset catalog image.
    static var legoRedBrick: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .legoRedBrick)
#else
        .init()
#endif
    }

    /// The "minifigure" asset catalog image.
    static var minifigure: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .minifigure)
#else
        .init()
#endif
    }

    /// The "setImage" asset catalog image.
    static var set: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .set)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "Gemini_Generated_Image_7vf8eq7vf8eq7vf8" asset catalog image.
    static var geminiGeneratedImage7Vf8Eq7Vf8Eq7Vf8: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .geminiGeneratedImage7Vf8Eq7Vf8Eq7Vf8)
#else
        .init()
#endif
    }

    /// The "RedLegoBrick" asset catalog image.
    static var redLegoBrick: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .redLegoBrick)
#else
        .init()
#endif
    }

    /// The "legoMinifigure" asset catalog image.
    static var legoMinifigure: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .legoMinifigure)
#else
        .init()
#endif
    }

    /// The "legoRedBrick" asset catalog image.
    static var legoRedBrick: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .legoRedBrick)
#else
        .init()
#endif
    }

    /// The "minifigure" asset catalog image.
    static var minifigure: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .minifigure)
#else
        .init()
#endif
    }

    /// The "setImage" asset catalog image.
    static var set: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .set)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

