//
//  SetTabs.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 9/3/25.
//

import Foundation

enum Tab: String, CaseIterable {
    case minifigs = "Minfigs"
    case parts = "Parts"
    case mocs = "MOCS"
    
    var systemImage: String {
        switch self {
            case .parts:
                return "shippingbox.fill"
            case .minifigs:
                return "person.fill"
            case .mocs:
                return "plus.circle.fill"
            
        }
    }
}

enum MinifigureTab: String, CaseIterable {
    case parts = "Parts"
    case sets = "Sets"
    
    var systemImage: String {
        switch self {
            case .parts:
                return "shippingbox.fill"
            case .sets:
                return "folder.fill"
        }
    }
}
