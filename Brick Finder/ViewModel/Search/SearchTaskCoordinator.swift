//
//  SearchTaskCoordinator.swift
//  Brick Finder
//

import Foundation

/// Cancels the previous in-flight search and skips redundant identical submissions.
final class SearchTaskCoordinator: @unchecked Sendable {
    private var task: Task<Void, Never>?
    private var lastSignature: String?

    func run(
        signature: String,
        force: Bool = false,
        operation: @escaping () async -> Void
    ) {
        if !force, signature == lastSignature, task != nil {
            return
        }
        lastSignature = signature
        task?.cancel()
        task = Task {
            await operation()
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
        lastSignature = nil
    }
}
