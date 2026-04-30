//
//  SettingViewModel.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 4/29/26.
//

import Foundation
import CloudKit

// MARK: - CloudKit / iCloud (read-only status for Settings)
@MainActor
final class CloudSyncStatusModel: ObservableObject {
    @Published private(set) var statusSummary = "Checking…"
    @Published private(set) var detailMessage = ""
    
    @MainActor
    func refresh() async {
        do {
            let status = try await CKContainer.default().accountStatus()
            switch status {
            case .available:
                statusSummary = "Active"
                detailMessage = "This device is signed in to iCloud. When you enable CloudKit in the app’s data store, your saved collection can sync across devices."
            case .noAccount:
                statusSummary = "Off"
                detailMessage = "Sign in to iCloud in Settings to use sync when CloudKit is enabled for Brick Finder."
            case .restricted:
                statusSummary = "Restricted"
                detailMessage = "iCloud is restricted on this device (often by parental controls or device management)."
            case .couldNotDetermine:
                statusSummary = "Unknown"
                detailMessage = "Could not determine iCloud status. Check your network connection and try again."
            case .temporarilyUnavailable:
                statusSummary = "Unavailable"
                detailMessage = "iCloud is temporarily unavailable. Try again later."
            @unknown default:
                statusSummary = "Unknown"
                detailMessage = "Unexpected account status."
            }
        } catch {
            statusSummary = "Error"
            detailMessage = error.localizedDescription
        }
    }
}
