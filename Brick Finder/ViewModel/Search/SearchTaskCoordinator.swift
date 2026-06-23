//
//  SearchTaskCoordinator.swift
//  Brick Finder
//

import Foundation

/// Cancels the previous in-flight search and skips redundant identical submissions.
final class SearchTaskCoordinator: @unchecked Sendable {
    private var task: Task<Void, Never>?
    private var lastSignature: String?

    /// Starts `operation`, cancelling any in-flight run. Returns `true` when a new
    /// run was actually started, or `false` when the identical search is already
    /// in flight and was skipped. Callers use the result to flip their loading
    /// flag synchronously (only when work really begins).
    @discardableResult
    func run(
        signature: String,
        force: Bool = false,
        operation: @escaping () async -> Void
    ) -> Bool {
        if !force, signature == lastSignature, task != nil {
            return false
        }
        lastSignature = signature
        task?.cancel()
        task = Task {
            await operation()
        }
        return true
    }

    func cancel() {
        task?.cancel()
        task = nil
        lastSignature = nil
    }
}
