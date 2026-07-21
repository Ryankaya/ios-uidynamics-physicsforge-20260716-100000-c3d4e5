import SwiftUI

struct LabView: View {
    @StateObject private var viewModel = LabViewModel()
    @State private var labResetTrigger = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Live preview canvas
                    LabCanvasRepresentable(viewModel: viewModel, reset: labResetTrigger)
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.systemFill)))
                        .padding(.horizontal)

                    // Material presets shortcut
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Material Presets")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(PhysicsMaterialPreset.allCases) { mat in
                                    Button {
                                        viewModel.apply(preset: mat)
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: mat.systemImage)
                                            Text(mat.displayName)
                                        }
                                        .font(.subheadline)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.accentColor.opacity(0.12))
                                        .foregroundStyle(Color.accentColor)
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Gravity section
                    paramSection(title: "Gravity") {
                        SliderRow(label: "Magnitude", value: $viewModel.gravityMagnitude, range: 0...3, format: "%.2f g")
                        SliderRow(label: "Angle (°)", value: $viewModel.gravityAngle, range: 0...360, format: "%.0f°")
                    }

                    // Material section
                    paramSection(title: "Material") {
                        SliderRow(label: "Elasticity", value: $viewModel.elasticity, range: 0...1, format: "%.2f")
                        SliderRow(label: "Friction", value: $viewModel.friction, range: 0...1, format: "%.2f")
                        SliderRow(label: "Density", value: $viewModel.density, range: 0.1...5, format: "%.1f")
                        SliderRow(label: "Angular Resistance", value: $viewModel.angularResistance, range: 0...1, format: "%.2f")
                        Toggle("Allows Rotation", isOn: $viewModel.allowsRotation)
                            .padding(.horizontal)
                    }

                    // Actions
                    HStack(spacing: 12) {
                        Button {
                            labResetTrigger.toggle()
                        } label: {
                            Label("Restart Demo", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button(role: .destructive) {
                            viewModel.reset()
                        } label: {
                            Label("Reset Params", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Lab")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func paramSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            VStack(spacing: 0) {
                content()
            }
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

// MARK: - Slider Row

private struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label).font(.subheadline)
                Spacer()
                Text(String(format: format, value))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range)
                .tint(.accentColor)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        Divider().padding(.horizontal)
    }
}

// MARK: - Lab Canvas (bouncing ball demo)

struct LabCanvasRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: LabViewModel
    let reset: Bool

    func makeUIView(context: Context) -> LabCanvas {
        LabCanvas()
    }

    func updateUIView(_ canvas: LabCanvas, context: Context) {
        canvas.configure(
            gravityVector: viewModel.gravityVector,
            elasticity: CGFloat(viewModel.elasticity),
            friction: CGFloat(viewModel.friction),
            density: CGFloat(viewModel.density),
            angularResistance: CGFloat(viewModel.angularResistance),
            allowsRotation: viewModel.allowsRotation
        )
    }
}

final class LabCanvas: UIView {
    private var animator: UIDynamicAnimator?
    private var balls: [UIView] = []
    private var gravity: UIGravityBehavior?
    private var itemBehaviors: [UIDynamicItemBehavior] = []
    private var physicsReady = false

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(spawnBall(_:)))
        addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !physicsReady, bounds.width > 0 else { return }
        physicsReady = true
        setupPhysics()
        spawnInitialBalls()
    }

    private func setupPhysics() {
        animator = UIDynamicAnimator(referenceView: self)
        let g = UIGravityBehavior()
        g.gravityDirection = CGVector(dx: 0, dy: 1)
        gravity = g
        let collision = UICollisionBehavior()
        collision.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(g)
        animator?.addBehavior(collision)
    }

    private func spawnInitialBalls() {
        let colors: [UIColor] = PhysicsColor.allCases.map { UIColor($0.swiftUIColor) }
        for i in 0..<5 {
            let x = bounds.width * CGFloat(i + 1) / 6
            let ball = makeBall(color: colors[i % colors.count])
            ball.center = CGPoint(x: x, y: 40)
            addSubview(ball)
            balls.append(ball)
        }
        applyPhysicsToBalls()
    }

    func configure(gravityVector: CGVector, elasticity: CGFloat, friction: CGFloat,
                   density: CGFloat, angularResistance: CGFloat, allowsRotation: Bool) {
        gravity?.gravityDirection = gravityVector

        // Update existing item behaviors
        for ib in itemBehaviors {
            ib.elasticity = elasticity
            ib.friction = friction
            ib.density = density
            ib.angularResistance = angularResistance
            ib.allowsRotation = allowsRotation
        }
    }

    private func applyPhysicsToBalls() {
        itemBehaviors.forEach { animator?.removeBehavior($0) }
        itemBehaviors.removeAll()

        for ball in balls {
            let ib = UIDynamicItemBehavior(items: [ball])
            ib.elasticity = 0.6
            ib.friction = 0.4
            ib.density = 1.0
            ib.allowsRotation = true
            animator?.addBehavior(ib)
            itemBehaviors.append(ib)

            if let collision = animator?.behaviors.compactMap({ $0 as? UICollisionBehavior }).first {
                collision.addItem(ball)
            }
            gravity?.addItem(ball)
        }
    }

    @objc private func spawnBall(_ recognizer: UITapGestureRecognizer) {
        guard balls.count < 12 else { return }
        let colors: [UIColor] = PhysicsColor.allCases.map { UIColor($0.swiftUIColor) }
        let ball = makeBall(color: colors[balls.count % colors.count])
        ball.center = recognizer.location(in: self)
        addSubview(ball)
        balls.append(ball)
        applyPhysicsToBalls()
    }

    private func makeBall(color: UIColor) -> UIView {
        let size: CGFloat = CGFloat.random(in: 24...40)
        let v = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        v.backgroundColor = color
        v.layer.cornerRadius = size / 2
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        return v
    }
}
