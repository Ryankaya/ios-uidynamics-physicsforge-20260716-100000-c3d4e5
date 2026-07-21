import UIKit

// SceneCanvas configures specific UIKit Dynamics preset scenes.
final class SceneCanvas: UIView {

    private var animator: UIDynamicAnimator?
    private var nodes: [UIView] = []
    private var attachments: [UIAttachmentBehavior] = []

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemFill.cgColor
        clipsToBounds = true
    }

    private var physicsReady = false

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !physicsReady, bounds.width > 0 else { return }
        physicsReady = true
        animator = UIDynamicAnimator(referenceView: self)
    }

    // MARK: - Preset loaders

    func loadPreset(_ preset: ScenePreset) {
        reset()
        guard bounds.width > 0 else { return }
        switch preset {
        case .pendulum:      loadPendulum()
        case .newtonsCradle: loadNewtonsCradle()
        case .avalanche:     loadAvalanche()
        case .springNetwork: loadSpringNetwork()
        case .orbits:        loadOrbits()
        }
    }

    func reset() {
        animator?.removeAllBehaviors()
        nodes.forEach { $0.removeFromSuperview() }
        nodes.removeAll()
        attachments.removeAll()
    }

    // MARK: - Pendulum
    // One ball on a string driven by gravity and UIAttachmentBehavior spring.

    private func loadPendulum() {
        let cx = bounds.midX
        let anchorY: CGFloat = 60
        let anchor = CGPoint(x: cx, y: anchorY)

        let ball = makeCircle(radius: 22, color: UIColor(PhysicsColor.coral.swiftUIColor))
        ball.center = CGPoint(x: cx + 120, y: anchorY + 150)
        addSubview(ball)
        nodes.append(ball)

        let gravity = UIGravityBehavior(items: [ball])
        gravity.magnitude = 1.0

        let spring = UIAttachmentBehavior(item: ball, attachedToAnchor: anchor)
        spring.length = 160
        spring.damping = 0.05      // nearly frictionless
        spring.frequency = 0.8
        attachments.append(spring)

        let ib = UIDynamicItemBehavior(items: [ball])
        ib.elasticity = 0.0
        ib.allowsRotation = false

        animator?.addBehavior(gravity)
        animator?.addBehavior(spring)
        animator?.addBehavior(ib)

        // Draw string with CAShapeLayer
        let stringLayer = CAShapeLayer()
        stringLayer.strokeColor = UIColor.systemGray3.cgColor
        stringLayer.lineWidth = 2
        stringLayer.fillColor = UIColor.clear.cgColor
        stringLayer.name = "pendulumString"
        layer.insertSublayer(stringLayer, at: 0)

        // Update string each frame
        let displayLink = CADisplayLink(target: self, selector: #selector(updatePendulumString(_:)))
        displayLink.add(to: .main, forMode: .default)

        // Keep displayLink alive in objc association
        objc_setAssociatedObject(self, &AssociatedKeys.displayLink, displayLink, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // Anchor dot
        let anchorDot = makeCircle(radius: 6, color: UIColor.systemGray2)
        anchorDot.center = anchor
        insertSubview(anchorDot, at: 0)
    }

    @objc private func updatePendulumString(_ link: CADisplayLink) {
        guard let ball = nodes.first,
              let stringLayer = layer.sublayers?.first(where: { $0.name == "pendulumString" }) as? CAShapeLayer else { return }
        let anchorY: CGFloat = 60
        let anchor = CGPoint(x: bounds.midX, y: anchorY)
        let path = UIBezierPath()
        path.move(to: anchor)
        path.addLine(to: ball.center)
        stringLayer.path = path.cgPath
    }

    // MARK: - Newton's Cradle
    // 5 steel balls on springs. Push the leftmost to see momentum transfer.

    private func loadNewtonsCradle() {
        let count = 5
        let radius: CGFloat = 18
        let diameter = radius * 2
        let gap: CGFloat = 1
        let totalWidth = CGFloat(count) * (diameter + gap) - gap
        let startX = bounds.midX - totalWidth / 2 + radius
        let anchorY: CGFloat = 50
        let restY = anchorY + 150
        let stringLength: CGFloat = 140

        let color = UIColor.systemGray2
        var balls: [UIView] = []

        let gravity = UIGravityBehavior()
        gravity.magnitude = 1.0

        let collision = UICollisionBehavior()

        for i in 0..<count {
            let ball = makeCircle(radius: radius, color: color)
            let cx = startX + CGFloat(i) * (diameter + gap)
            ball.center = CGPoint(x: cx, y: restY)
            addSubview(ball)
            nodes.append(ball)
            balls.append(ball)

            gravity.addItem(ball)
            collision.addItem(ball)

            let anchor = CGPoint(x: cx, y: anchorY)
            let spring = UIAttachmentBehavior(item: ball, attachedToAnchor: anchor)
            spring.length = stringLength
            spring.damping = 0.02
            spring.frequency = 1.5
            attachments.append(spring)
            animator?.addBehavior(spring)

            let ib = UIDynamicItemBehavior(items: [ball])
            ib.elasticity = 1.0        // perfectly elastic
            ib.friction = 0.0
            ib.density = 1.0
            ib.allowsRotation = false
            animator?.addBehavior(ib)
        }

        animator?.addBehavior(gravity)
        animator?.addBehavior(collision)

        // Pull first ball back and release
        if let first = balls.first {
            let pull = UIAttachmentBehavior(item: first, attachedToAnchor: CGPoint(x: first.center.x - 110, y: anchorY))
            pull.length = stringLength
            pull.damping = 1.0
            pull.frequency = 10
            animator?.addBehavior(pull)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.animator?.removeBehavior(pull)
            }
        }
    }

    // MARK: - Avalanche
    // A pyramid of colored blocks stacked, all released under gravity.

    private func loadAvalanche() {
        let rows = 5
        let blockSize: CGFloat = 34
        let gap: CGFloat = 3
        let baseY = bounds.height - 60
        let colors: [UIColor] = PhysicsColor.allCases.map { UIColor($0.swiftUIColor) }

        let gravity = UIGravityBehavior()
        let collision = UICollisionBehavior()
        collision.translatesReferenceBoundsIntoBoundary = true

        var allBlocks: [UIView] = []

        for row in 0..<rows {
            let count = rows - row
            let rowWidth = CGFloat(count) * (blockSize + gap) - gap
            let startX = bounds.midX - rowWidth / 2
            let y = baseY - CGFloat(row) * (blockSize + gap)

            for col in 0..<count {
                let x = startX + CGFloat(col) * (blockSize + gap)
                let block = UIView(frame: CGRect(x: x, y: y, width: blockSize, height: blockSize))
                block.backgroundColor = colors[(row * 3 + col) % colors.count].withAlphaComponent(0.9)
                block.layer.cornerRadius = 6
                block.layer.borderWidth = 1
                block.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor

                addSubview(block)
                nodes.append(block)
                allBlocks.append(block)
                gravity.addItem(block)
                collision.addItem(block)

                let ib = UIDynamicItemBehavior(items: [block])
                ib.elasticity = 0.45
                ib.friction = 0.7
                ib.density = 2.0
                ib.allowsRotation = true
                animator?.addBehavior(ib)
            }
        }

        animator?.addBehavior(gravity)
        animator?.addBehavior(collision)

        // After a brief pause, nudge the pyramid
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self, weak animator] in
            guard let self, let animator else { return }
            let push = UIPushBehavior(items: allBlocks, mode: .instantaneous)
            push.pushDirection = CGVector(dx: 0.3, dy: -0.8)
            push.magnitude = 0.3
            push.action = { [weak push] in
                if let push { animator.removeBehavior(push) }
            }
            animator.addBehavior(push)
        }
    }

    // MARK: - Spring Network
    // Grid of balls interconnected by UIAttachmentBehavior springs.

    private func loadSpringNetwork() {
        let cols = 4
        let rows = 4
        let spacing: CGFloat = (bounds.width - 60) / CGFloat(cols - 1)
        let startX: CGFloat = 30
        let startY: CGFloat = 80
        let radius: CGFloat = 14
        let colors: [UIColor] = PhysicsColor.allCases.map { UIColor($0.swiftUIColor) }

        var grid: [[UIView]] = []
        let gravity = UIGravityBehavior()
        gravity.magnitude = 0.3

        // Create nodes
        for r in 0..<rows {
            var row: [UIView] = []
            for c in 0..<cols {
                let cx = startX + CGFloat(c) * spacing
                let cy = startY + CGFloat(r) * spacing
                let ball = makeCircle(radius: radius, color: colors[(r * cols + c) % colors.count])
                ball.center = CGPoint(x: cx, y: cy)
                addSubview(ball)
                nodes.append(ball)
                row.append(ball)

                // Pin top row to ceiling
                if r == 0 {
                    let pin = UIAttachmentBehavior(item: ball, attachedToAnchor: CGPoint(x: cx, y: startY))
                    pin.length = 0
                    pin.damping = 1.0
                    pin.frequency = 10
                    attachments.append(pin)
                    animator?.addBehavior(pin)
                } else {
                    gravity.addItem(ball)
                    let ib = UIDynamicItemBehavior(items: [ball])
                    ib.elasticity = 0.3
                    ib.density = 0.5
                    ib.allowsRotation = false
                    animator?.addBehavior(ib)
                }
            }
            grid.append(row)
        }

        animator?.addBehavior(gravity)

        // Connect adjacent nodes with springs
        for r in 0..<rows {
            for c in 0..<cols {
                let current = grid[r][c]
                if c + 1 < cols {
                    let spring = UIAttachmentBehavior(item: current, attachedTo: grid[r][c + 1])
                    spring.length = spacing
                    spring.damping = 0.3
                    spring.frequency = 3.0
                    attachments.append(spring)
                    animator?.addBehavior(spring)
                }
                if r + 1 < rows {
                    let spring = UIAttachmentBehavior(item: current, attachedTo: grid[r + 1][c])
                    spring.length = spacing
                    spring.damping = 0.3
                    spring.frequency = 3.0
                    attachments.append(spring)
                    animator?.addBehavior(spring)
                }
            }
        }

        // Disturb center after a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, weak animator] in
            guard let animator else { return }
            let center = grid[rows / 2][cols / 2]
            let push = UIPushBehavior(items: [center], mode: .instantaneous)
            push.pushDirection = CGVector(dx: 0, dy: 1)
            push.magnitude = 0.8
            push.action = { [weak push] in
                if let push { animator.removeBehavior(push) }
            }
            animator.addBehavior(push)
        }
    }

    // MARK: - Orbits
    // Balls attached at a fixed radius from center, given tangential push.

    private func loadOrbits() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radii: [CGFloat] = [70, 110, 155]
        let counts = [4, 6, 8]
        let colors: [UIColor] = PhysicsColor.allCases.map { UIColor($0.swiftUIColor) }

        // No gravity for orbits
        for (orbitIdx, radius) in radii.enumerated() {
            let count = counts[orbitIdx]
            for i in 0..<count {
                let angle = (2 * Double.pi / Double(count)) * Double(i)
                let x = center.x + radius * CGFloat(cos(angle))
                let y = center.y + radius * CGFloat(sin(angle))
                let ball = makeCircle(radius: 10 + CGFloat(orbitIdx) * 3,
                                     color: colors[(orbitIdx * 3 + i) % colors.count])
                ball.center = CGPoint(x: x, y: y)
                addSubview(ball)
                nodes.append(ball)

                // Spring attachment to center anchor
                let attachment = UIAttachmentBehavior(item: ball, attachedToAnchor: center)
                attachment.length = radius
                attachment.damping = 0.05
                attachment.frequency = 0.5
                attachments.append(attachment)
                animator?.addBehavior(attachment)

                let ib = UIDynamicItemBehavior(items: [ball])
                ib.density = 0.3
                ib.allowsRotation = false
                ib.elasticity = 0.5
                animator?.addBehavior(ib)

                // Tangential push to create orbital motion
                let tangentialAngle = angle + .pi / 2
                let speed: CGFloat = 0.4 + CGFloat(orbitIdx) * 0.1
                let push = UIPushBehavior(items: [ball], mode: .instantaneous)
                push.pushDirection = CGVector(dx: CGFloat(cos(tangentialAngle)) * speed,
                                              dy: CGFloat(sin(tangentialAngle)) * speed)
                push.magnitude = speed
                push.action = { [weak push, weak self] in
                    if let push { self?.animator?.removeBehavior(push) }
                }
                animator?.addBehavior(push)
            }
        }

        // Center dot
        let dot = makeCircle(radius: 8, color: .systemGray2)
        dot.center = center
        insertSubview(dot, at: 0)
    }

    // MARK: - Helpers

    private func makeCircle(radius: CGFloat, color: UIColor) -> UIView {
        let size = radius * 2
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        view.backgroundColor = color
        view.layer.cornerRadius = radius
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 3
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        return view
    }
}

private enum AssociatedKeys {
    static var displayLink = "displayLink"
}
