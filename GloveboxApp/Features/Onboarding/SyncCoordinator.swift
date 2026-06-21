import Foundation
import SwiftData
import Observation

/// Drives the offline-cache pipeline for a vehicle: steps through the five
/// resource sections, persisting each as it "caches," and finalizes the
/// vehicle's ready/synced state.
///
/// Caching is currently the generation of clearly-labeled placeholder content
/// (no real source wired up yet). The per-section structure is the seam where a
/// real fetch (owner's manual + issue reference) slots in later.
@MainActor
@Observable
final class SyncCoordinator {
    enum Phase: Equatable { case idle, syncing, done }

    private(set) var phase: Phase = .idle
    private(set) var progress: Double = 0     // 0...1
    private(set) var completedSections: Set<String> = []

    let sections = SyncSection.allCases

    private var task: Task<Void, Never>?

    /// Returns whether a given section has finished caching (for the checklist).
    func isDone(_ section: SyncSection) -> Bool { completedSections.contains(section.rawValue) }

    func start(vehicle: Vehicle, context: ModelContext) {
        guard phase != .syncing else { return }
        // Reset any prior cache for a clean re-sync.
        for chunk in vehicle.manualChunks { context.delete(chunk) }
        vehicle.ready = false
        completedSections = []
        progress = 0
        phase = .syncing

        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            let total = sections.count
            for (index, section) in sections.enumerated() {
                if Task.isCancelled { return }
                // Simulated per-section caching latency. TODO: real fetch here.
                try? await Task.sleep(for: .milliseconds(550))
                if Task.isCancelled { return }

                PlaceholderManualData.makeChunks(for: vehicle, section: section, in: context)
                completedSections.insert(section.rawValue)
                progress = Double(index + 1) / Double(total)
            }

            // Finalize.
            let bytes = PlaceholderManualData.approximateCacheBytes(for: vehicle.manualChunks)
            vehicle.cacheBytes = bytes
            vehicle.ready = true
            vehicle.syncedAt = Date()
            try? context.save()
            phase = .done
        }
    }

    func cancel() {
        task?.cancel()
        if phase == .syncing { phase = .idle }
    }
}
