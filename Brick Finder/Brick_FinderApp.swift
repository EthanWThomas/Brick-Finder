//
//  Brick_FinderApp.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 1/27/25.
//

import SwiftUI

@main
struct Brick_FinderApp: App {
    @AppStorage("appPreferredColorScheme") private var preferredColorScheme = "system"
    
    private var resolvedColorScheme: ColorScheme? {
        switch preferredColorScheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabNavigation()
                .preferredColorScheme(resolvedColorScheme)
        }
    }
}
