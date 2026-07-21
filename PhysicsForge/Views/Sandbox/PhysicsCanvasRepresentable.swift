import SwiftUI
import UIKit

struct PhysicsCanvasRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: SandboxViewModel

    func makeUIView(context: Context) -> PhysicsCanvas {
        let canvas = PhysicsCanvas()

        canvas.onStatsUpdate = { count, simulating in
            Task { @MainActor in
                viewModel.updateStats(objectCount: count, isSimulating: simulating)
            }
        }

        canvas.onObjectTapped = { point in
            Task { @MainActor in
                viewModel.objectTapped(at: point)
            }
        }

        return canvas
    }

    func updateUIView(_ canvas: PhysicsCanvas, context: Context) {
        // Sync selection state so the next tap uses current settings
        canvas.currentShape = viewModel.selectedShape
        canvas.currentColor = viewModel.selectedColor.uiColor
        canvas.currentElasticity = viewModel.selectedMaterial.elasticity
        canvas.currentFriction = viewModel.selectedMaterial.friction
        canvas.currentDensity = viewModel.selectedMaterial.density
        canvas.currentAngularResistance = viewModel.selectedMaterial.angularResistance

        // Apply gravity
        canvas.setGravity(direction: viewModel.gravityPreset.gravityDirection)

        // Execute pending one-shot commands
        if let cmd = viewModel.pendingCommand {
            switch cmd {
            case .clearAll:    canvas.clearAll()
            case .shake:       canvas.shake()
            case .snapAll:     canvas.snapRandom()
            case .applyPush:
                canvas.shake()  // simplified: reuse shake for arbitrary push
            }
            viewModel.pendingCommand = nil
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject {}
}
