//
//  SettingView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 4/15/26.
//

import SwiftUI
import CloudKit
import StoreKit

// MARK: - CloudKit / iCloud (read-only status for Settings)

@MainActor
final class CloudSyncStatusModel: ObservableObject {
    @Published private(set) var statusSummary = "Checking…"
    @Published private(set) var detailMessage = ""
    
//    func refresh() async {
//        do {
//            let status = try await CKContainer.default().accountStatus()
//            switch status {
//            case .available:
//                statusSummary = "Active"
//                detailMessage = "This device is signed in to iCloud. When you enable CloudKit in the app’s data store, your saved collection can sync across devices."
//            case .noAccount:
//                statusSummary = "Off"
//                detailMessage = "Sign in to iCloud in Settings to use sync when CloudKit is enabled for Brick Finder."
//            case .restricted:
//                statusSummary = "Restricted"
//                detailMessage = "iCloud is restricted on this device (often by parental controls or device management)."
//            case .couldNotDetermine:
//                statusSummary = "Unknown"
//                detailMessage = "Could not determine iCloud status. Check your network connection and try again."
//            case .temporarilyUnavailable:
//                statusSummary = "Unavailable"
//                detailMessage = "iCloud is temporarily unavailable. Try again later."
//            @unknown default:
//                statusSummary = "Unknown"
//                detailMessage = "Unexpected account status."
//            }
//        } catch {
//            statusSummary = "Error"
//            detailMessage = error.localizedDescription
//        }
//    }
}

// MARK: - Settings

struct SettingView: View {
    @AppStorage("appNotificationsEnabled") private var notificationsEnabled = false
    @AppStorage("appPreferredColorScheme") private var preferredColorScheme = "system"
    
    @State private var searchText = ""
    
    @StateObject private var cloudSync = CloudSyncStatusModel()
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    
    private let rebrickableURL = URL(string: "https://rebrickable.com/")!
    private let bricksetURL = URL(string: "https://brickset.com/")!
    
    /// Placeholder App Store URL — replace with your live app link for Share / marketing.
    private var appStoreShareURL: URL {
        URL(string: "https://apps.apple.com/app/brick-finder/id000000000")!
    }
    
    private var privacyPolicyURL: URL {
        URL(string: "https://rebrickable.com/legal/")!
    }
    
    private var termsURL: URL {
        URL(string: "https://brickset.com/about/")!
    }
    
    private var cookiesURL: URL {
        URL(string: "https://brickset.com/about/")!
    }
    
    var body: some View {
        List {
            if matchesSearch("Preferences", "Notifications") {
                preferencesSection
            }
            if matchesSearch("Sync", "Display", "Cloud", "iCloud", "Light", "Dark", "Appearance") {
                cloudAndDisplaySection
            }
            if matchesSearch("Support", "Rate", "Share", "Contact", "Feedback") {
                supportSection
            }
            if matchesSearch("Legal", "Privacy", "Terms", "Cookies") {
                legalSection
            }
            if matchesSearch("About", "Rebrickable", "Brickset", "API", "Credits") {
                aboutSection
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search settings")
        .listRowSeparatorTint(Color.primary.opacity(0.12))
//        .task {
//            await cloudSync.refresh()
//        }
    }
    
    // MARK: Sections
    
    private var preferencesSection: some View {
        Section {
            Toggle(isOn: $notificationsEnabled) {
                settingsLabel("Notifications", systemImage: "bell", filled: notificationsEnabled)
            }
            .tint(.accentColor)
        } header: {
            sectionHeader("Preferences")
        }
    }
    
    private var cloudAndDisplaySection: some View {
        Section {
            NavigationLink {
                CloudSyncDetailView(viewModel: cloudSync)
            } label: {
                HStack(spacing: 12) {
                    settingsIcon("icloud", filled: false)
                    Text("Cloud Sync")
                        .font(.body)
                    Spacer(minLength: 8)
                    Text(cloudSync.statusSummary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .accessibilityElement(children: .combine)
            }
            
            NavigationLink {
                DisplaySettingsView(preferredColorScheme: $preferredColorScheme)
            } label: {
                settingsLabel("Display", systemImage: "sun.max", filled: false)
            }
        } header: {
            sectionHeader("Sync & display")
        }
    }
    
    private var supportSection: some View {
        Section {
            Button {
                requestReview()
            } label: {
                settingsLabel("Rate App", systemImage: "star", filled: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(.primary)
            
            ShareLink(item: appStoreShareURL, message: Text("Check out Brick Finder")) {
                settingsLabel("Share App", systemImage: "square.and.arrow.up", filled: false)
            }
            
            Button {
                if let url = URL(string: "mailto:support@example.com?subject=Brick%20Finder%20—%20Contact") {
                    openURL(url)
                }
            } label: {
                settingsLabel("Contact", systemImage: "envelope", filled: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(.primary)
            
            Button {
                if let url = URL(string: "mailto:support@example.com?subject=Brick%20Finder%20—%20Feedback") {
                    openURL(url)
                }
            } label: {
                settingsLabel("Feedback", systemImage: "bubble.left", filled: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(.primary)
        } header: {
            sectionHeader("Support")
        }
    }
    
    private var legalSection: some View {
        Section {
            Link(destination: privacyPolicyURL) {
                settingsLabel("Privacy Policy", systemImage: "lock", filled: false)
            }
            Link(destination: termsURL) {
                settingsLabel("Terms and Conditions", systemImage: "doc.text", filled: false)
            }
            Link(destination: cookiesURL) {
                settingsLabel("Cookies Policy", systemImage: "doc.badge.plus", filled: false)
            }
        } header: {
            sectionHeader("Legal")
        }
    }
    
    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text(apiCreditsText)
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 16) {
                    Link(destination: rebrickableURL) {
                        Label("Rebrickable", systemImage: "link")
                            .font(.subheadline.weight(.semibold))
                    }
                    Link(destination: bricksetURL) {
                        Label("Brickset", systemImage: "link")
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
            .padding(.vertical, 4)
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        } header: {
            sectionHeader("About")
        } footer: {
            Text("Data is provided by third-party APIs. Brick Finder is not affiliated with the LEGO Group.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    private var apiCreditsText: String {
        "Brick Finder utilizes the Rebrickable API and the Brickset API to provide comprehensive and up-to-date information on LEGO sets, parts, and minifigures. We are grateful to the teams at Rebrickable and Brickset for their dedication to the LEGO community and for making this data available to the public."
    }
    
    private func matchesSearch(_ tokens: String...) -> Bool {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return true }
        return tokens.contains { $0.localizedStandardContains(q) }
    }
    
    // MARK: Row chrome
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(nil)
    }
    
    private func settingsLabel(_ title: String, systemImage: String, filled: Bool) -> some View {
        HStack(spacing: 12) {
            settingsIcon(systemImage, filled: filled)
            Text(title)
                .font(.body)
        }
    }
    
    private func settingsIcon(_ systemName: String, filled: Bool) -> some View {
        Image(systemName: filled ? "\(systemName).fill" : systemName)
            .font(.body.weight(.medium))
            .symbolRenderingMode(.hierarchical)
            .frame(width: 28, alignment: .center)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Cloud Sync detail

private struct CloudSyncDetailView: View {
    @ObservedObject var viewModel: CloudSyncStatusModel
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        List {
            Section {
                LabeledContent("iCloud status", value: viewModel.statusSummary)
                Text(viewModel.detailMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Section {
                Button("Refresh status") {
//                    Task { await viewModel.refresh() }
                }
                Button("Open iCloud & Apple ID Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
            }
        }
        .navigationTitle("Cloud Sync")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Display (light / dark / system)

private struct DisplaySettingsView: View {
    @Binding var preferredColorScheme: String
    
    var body: some View {
        List {
            Section {
                Picker("Appearance", selection: $preferredColorScheme) {
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                    Text("Automatic").tag("system")
                }
                .pickerStyle(.inline)
            } footer: {
                Text("Automatic follows the system setting. This applies across Brick Finder.")
                    .font(.caption)
            }
        }
        .navigationTitle("Display")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingView()
    }
}
