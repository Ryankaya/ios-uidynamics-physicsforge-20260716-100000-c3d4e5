import Foundation

struct SpawnRecord: Identifiable, Codable {
    let id: UUID
    let shape: PhysicsShape
    let color: PhysicsColor
    let material: PhysicsMaterialPreset
    let timestamp: Date

    init(shape: PhysicsShape, color: PhysicsColor, material: PhysicsMaterialPreset) {
        self.id = UUID()
        self.shape = shape
        self.color = color
        self.material = material
        self.timestamp = Date()
    }
}

struct GravityChangeRecord: Identifiable, Codable {
    let id: UUID
    let preset: GravityPreset
    let timestamp: Date

    init(preset: GravityPreset) {
        self.id = UUID()
        self.preset = preset
        self.timestamp = Date()
    }
}

struct SessionStats {
    var totalSpawned: Int = 0
    var currentObjectCount: Int = 0
    var isSimulating: Bool = false
    var pauseCount: Int = 0
    var clearCount: Int = 0
    var shakeCount: Int = 0
    var sessionStart: Date = Date()

    var shapeCounts: [PhysicsShape: Int] = Dictionary(
        uniqueKeysWithValues: PhysicsShape.allCases.map { ($0, 0) }
    )
    var materialCounts: [PhysicsMaterialPreset: Int] = Dictionary(
        uniqueKeysWithValues: PhysicsMaterialPreset.allCases.map { ($0, 0) }
    )
    var gravityCounts: [GravityPreset: Int] = Dictionary(
        uniqueKeysWithValues: GravityPreset.allCases.map { ($0, 0) }
    )

    var sessionDuration: TimeInterval { Date().timeIntervalSince(sessionStart) }

    var formattedDuration: String {
        let secs = Int(sessionDuration)
        let m = secs / 60
        let s = secs % 60
        return String(format: "%d:%02d", m, s)
    }

    mutating func record(spawn record: SpawnRecord) {
        totalSpawned += 1
        currentObjectCount += 1
        shapeCounts[record.shape, default: 0] += 1
        materialCounts[record.material, default: 0] += 1
    }

    mutating func recordClear() {
        clearCount += 1
        currentObjectCount = 0
    }

    mutating func recordGravityChange(_ preset: GravityPreset) {
        gravityCounts[preset, default: 0] += 1
    }
}
