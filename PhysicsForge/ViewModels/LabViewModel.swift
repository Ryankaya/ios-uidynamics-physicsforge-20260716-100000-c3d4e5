import SwiftUI

@MainActor
final class LabViewModel: ObservableObject {

    // Gravity fine-tune
    @Published var gravityMagnitude: Double = 1.0
    @Published var gravityAngle: Double = 90.0   // degrees, 90 = downward

    // Material fine-tune
    @Published var elasticity: Double = 0.6
    @Published var friction: Double = 0.4
    @Published var density: Double = 1.0
    @Published var angularResistance: Double = 0.2
    @Published var allowsRotation: Bool = true

    // Computed gravity direction from angle
    var gravityVector: CGVector {
        let radians = gravityAngle * .pi / 180.0
        return CGVector(
            dx: cos(radians) * gravityMagnitude,
            dy: sin(radians) * gravityMagnitude
        )
    }

    // Build a PhysicsMaterialPreset-compatible tuple for PhysicsCanvas
    var customMaterial: (elasticity: CGFloat, friction: CGFloat, density: CGFloat, angularResistance: CGFloat, allowsRotation: Bool) {
        (CGFloat(elasticity), CGFloat(friction), CGFloat(density), CGFloat(angularResistance), allowsRotation)
    }

    func reset() {
        gravityMagnitude = 1.0
        gravityAngle = 90.0
        elasticity = 0.6
        friction = 0.4
        density = 1.0
        angularResistance = 0.2
        allowsRotation = true
    }

    func apply(preset: PhysicsMaterialPreset) {
        elasticity = preset.elasticity
        friction = preset.friction
        density = preset.density
        angularResistance = preset.angularResistance
    }
}
