//
//  TabNavigation.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/6/25.
//

import SwiftUI
import SwiftData

struct TabNavigation: View {
    /// Top-level navigation destinations shared by the compact tab bar and the
    /// regular-width sidebar.
    private enum NavSection: Int, CaseIterable, Identifiable, Hashable {
        case home, minifigures, sets, parts, settings

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .home: return "Home"
            case .minifigures: return "Minifigures"
            case .sets: return "Sets"
            case .parts: return "Parts"
            case .settings: return "Settings"
            }
        }

        var systemImage: String {
            switch self {
            case .home: return "house"
            case .minifigures: return "person.crop.circle"
            case .sets: return "folder.fill"
            case .parts: return "square.and.arrow.down"
            case .settings: return "slider.horizontal.3"
            }
        }
    }

    @State private var selectedTab = 0
    @State private var sidebarSelection: NavSection? = .home
    @State private var searchText: String = ""
    @StateObject private var themeViewModel = ThemeViewModel()
    @StateObject private var partCategoryViewModel = PartCategoryViewModel()

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let cantainer: ModelContainer
    
    init() {
        do {
            self.cantainer = try ModelContainer(for: LegoSetsDataModel.self, LegoDataModel.self, LegoPartsDataModel.self)
        } catch {
            NSLog("SwiftData ModelContainer failed: \(error.localizedDescription). Falling back to in-memory store.")
            do {
                let memory = ModelConfiguration(isStoredInMemoryOnly: true)
                self.cantainer = try ModelContainer(
                    for: LegoSetsDataModel.self, LegoDataModel.self, LegoPartsDataModel.self,
                    configurations: memory
                )
            } catch {
                fatalError("Could not load SwiftData container: \(error)")
            }
        }
    }
  
    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                splitView
            } else {
                tabView
            }
        }
        .background(Color("TabbarColor"))
    }

    // MARK: - Compact (iPhone) tab bar

    private var tabView: some View {
        TabView(selection: $selectedTab) {
            homeScreen
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            minifiguresScreen
                .tabItem { Label("Minifigures", systemImage: "person.crop.circle") }
                .tag(1)

            setsScreen
                .tabItem { Label("Sets", systemImage: "folder.fill") }
                .tag(2)

            partsScreen
                .tabItem { Label("Parts", systemImage: "square.and.arrow.down") }
                .tag(3)
        }
    }

    // MARK: - Regular (iPad) multi-column navigation

    private var splitView: some View {
        NavigationSplitView {
            List(selection: $sidebarSelection) {
                ForEach(NavSection.allCases) { section in
                    Label(section.title, systemImage: section.systemImage)
                        .tag(section)
                }
            }
            .navigationTitle("Brick Finder")
            .listStyle(.sidebar)
        } detail: {
            detailContent(for: sidebarSelection ?? .home)
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private func detailContent(for section: NavSection) -> some View {
        switch section {
        case .home:
            homeScreen
        case .minifigures:
            minifiguresScreen
        case .sets:
            setsScreen
        case .parts:
            partsScreen
        case .settings:
            NavigationStack {
                SettingView()
            }
        }
    }

    // MARK: - Shared screen builders (identical wiring for both layouts)

    private var homeScreen: some View {
        HomeView(context: ModelContext(cantainer))
            .environmentObject(themeViewModel)
            .modelContainer(cantainer)
    }

    private var minifiguresScreen: some View {
        MinifiguresScreen(context: ModelContext(cantainer))
            .environmentObject(themeViewModel)
            .modelContainer(cantainer)
    }

    private var setsScreen: some View {
        SetsScreen(context: ModelContext(cantainer))
            .environmentObject(themeViewModel)
            .modelContainer(cantainer)
    }

    private var partsScreen: some View {
        PartsScreen(context: ModelContext(cantainer))
            .environmentObject(partCategoryViewModel)
            .modelContainer(cantainer)
    }
}

#Preview {
    TabNavigation()
}
