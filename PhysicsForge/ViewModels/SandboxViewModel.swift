import SwiftUI
import Combine

enum CanvasCommand: Equatable {
    case clearAll
    case shake
    case applyPush(CGVector)
    case snapAll
}

@MainActor
final class SandboxViewModel: ObservableObject {

    // MARK: - Selection state

    @Published var selectedShape: PhysicsShape = .circle
    @Published var selectedColor: PhysicsColor = .coral
    @Published var selectedMaterial: PhysicsMaterialPreset = .rubber
    @Published var gravityPreset: GravityPreset = .earth

    // MARK: - Canvas live stats (written by PhysicsCanvas callback)

    @Published var objectCount: Int = 0
    @Published var isSimulating: Bool = false

    // MARK: - Commands dispatched to PhysicsCanvas via updateUIView

    @Published var pendingCommand: CanvasCommand? = nil

    // MARK: - Shared metrics (injected)

    var metricsViewModel: MetricsViewModel?

    // MARK: - Actions

    func objectTapped(at point: CGPoint) {
        let record = SpawnRecord(shape: selectedShape, color: selectedColor, material: selectedMaterial)
        metricsViewModel?.record(spawn: record)
    }

    func clearAll() {
        pendingCommand = .clearAll
        metricsViewModel?.recordClear()
    }

    func shake() {
        pendingCommand = .shake
        metricsViewModel?.stats.shakeCount += 1
    }

    func applyPush(_ vector: CGVector) {
        pendingCommand = .applyPush(vector)
    }

    func snapAll() {
        pendingCommand = .snapAll
    }

    func gravityChanged(to preset: GravityPreset) {
        gravityPreset = preset
        metricsViewModel?.recordGravityChange(preset)
    }

    // MARK: - Callback from PhysicsCanvas

    func updateStats(objectCount: Int, isSimulating: Bool) {
        self.objectCount = objectCount
        self.isSimulating = isSimulating
        metricsViewModel?.stats.currentObjectCount = objectCount
        metricsViewModel?.stats.isSimulating = isSimulating
        if !isSimulating {
            metricsViewModel?.stats.pauseCount += 1
        }
    }
}
