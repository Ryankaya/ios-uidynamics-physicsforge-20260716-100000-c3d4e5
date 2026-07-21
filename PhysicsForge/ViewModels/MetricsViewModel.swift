import SwiftUI
import Combine

@MainActor
final class MetricsViewModel: ObservableObject {
    @Published var stats = SessionStats()
    @Published var spawnHistory: [SpawnRecord] = []
    @Published var gravityHistory: [GravityChangeRecord] = []

    private var timer: AnyCancellable?

    init() {
        // Refresh session duration every second
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    func record(spawn record: SpawnRecord) {
        spawnHistory.append(record)
        stats.record(spawn: record)
    }

    func recordClear() {
        stats.recordClear()
    }

    func recordGravityChange(_ preset: GravityPreset) {
        let record = GravityChangeRecord(preset: preset)
        gravityHistory.append(record)
        stats.recordGravityChange(preset)
    }

    // Sorted shape distribution for display
    var shapeDistribution: [(shape: PhysicsShape, count: Int)] {
        PhysicsShape.allCases
            .map { (shape: $0, count: stats.shapeCounts[$0, default: 0]) }
            .sorted { $0.count > $1.count }
    }

    // Top gravity presets used
    var topGravityPresets: [(preset: GravityPreset, count: Int)] {
        GravityPreset.allCases
            .map { (preset: $0, count: stats.gravityCounts[$0, default: 0]) }
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
    }

    var mostUsedMaterial: PhysicsMaterialPreset? {
        stats.materialCounts.max(by: { $0.value < $1.value })?.key
    }
}
