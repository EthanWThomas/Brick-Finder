//
//  CatagoryItem.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/12/25.
//

import Foundation
import SwiftUICore

// MARK: - Data Models
struct CategoryItem: Identifiable {
    let id: Int
    let title: String
    let icon: String
    let count: Int
    let color: Color
}

struct RecentItem: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
}
