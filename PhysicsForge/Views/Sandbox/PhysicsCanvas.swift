import UIKit

// PhysicsCanvas owns the UIDynamicAnimator and manages all physics objects.
// It is driven externally via its public methods (called from UIViewRepresentable).
final class PhysicsCanvas: UIView {

    // MARK: - Callbacks

    var onStatsUpdate: ((_ objectCount: Int, _ isSimulating: Bool) -> Void)?
    var onObjectTapped: ((_ point: CGPoint) -> Void)?

    // MARK: - Current settings (set by UIViewRepresentable updateUIView)

    var currentShape: PhysicsShape = .circle
    var currentColor: UIColor = .systemOrange
    var currentElasticity: CGFloat = 0.6
    var currentFriction: CGFloat = 0.4
    var currentDensity: CGFloat = 1.0
    var currentAngularResistance: CGFloat = 0.2
    var currentAllowsRotation: Bool = true

    // MARK: - Physics internals

    private var animator: UIDynamicAnimator!
    private var gravityBehavior: UIGravityBehavior!
    private var collisionBehavior: UICollisionBehavior!
    private var nodes: [PhysicsNode] = []
    private var itemBehaviors: [ObjectIdentifier: UIDynamicItemBehavior] = [:]

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemFill.cgColor
        clipsToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)

        let drag = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        addGestureRecognizer(drag)
    }

    // Setup is deferred until the view has a non-zero frame (layoutSubviews)
    private var physicsReady = false

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !physicsReady, bounds.width > 0 else { return }
        physicsReady = true
        setupPhysics()
    }

    private func setupPhysics() {
        animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self

        gravityBehavior = UIGravityBehavior()
        gravityBehavior.gravityDirection = CGVector(dx: 0, dy: 1)

        collisionBehavior = UICollisionBehavior()
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true

        animator.addBehavior(gravityBehavior)
        animator.addBehavior(collisionBehavior)
    }

    // MARK: - Public interface

    func addNode(at point: CGPoint) {
        guard physicsReady else { return }

        let node = PhysicsNode(shape: currentShape, color: currentColor, at: point)
        addSubview(node)

        gravityBehavior.addItem(node)
        collisionBehavior.addItem(node)

        let ib = UIDynamicItemBehavior(items: [node])
        ib.elasticity = currentElasticity
        ib.friction = currentFriction
        ib.density = currentDensity
        ib.angularResistance = currentAngularResistance
        ib.allowsRotation = currentAllowsRotation
        animator.addBehavior(ib)
        itemBehaviors[ObjectIdentifier(node)] = ib

        nodes.append(node)
        onStatsUpdate?(nodes.count, true)
    }

    func clearAll() {
        guard physicsReady else { return }
        nodes.forEach { node in
            if let ib = itemBehaviors[ObjectIdentifier(node)] {
                animator.removeBehavior(ib)
            }
            node.removeFromSuperview()
        }
        nodes.removeAll()
        itemBehaviors.removeAll()

        // Rebuild gravity and collision without stale references
        animator.removeBehavior(gravityBehavior)
        animator.removeBehavior(collisionBehavior)
        gravityBehavior = UIGravityBehavior()
        collisionBehavior = UICollisionBehavior()
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(gravityBehavior)
        animator.addBehavior(collisionBehavior)

        onStatsUpdate?(0, false)
    }

    func setGravity(direction: CGVector) {
        gravityBehavior?.gravityDirection = direction
    }

    func shake() {
        guard !nodes.isEmpty else { return }
        let push = UIPushBehavior(items: nodes, mode: .instantaneous)
        push.pushDirection = CGVector(
            dx: CGFloat.random(in: -1.5...1.5),
            dy: CGFloat.random(in: -1.5...0)
        )
        push.magnitude = 1.8
        push.action = { [weak push, weak self] in
            if let push { self?.animator?.removeBehavior(push) }
        }
        animator.addBehavior(push)
    }

    func snapRandom() {
        guard !nodes.isEmpty else { return }
        let target = CGPoint(x: bounds.midX, y: bounds.midY * 0.6)
        nodes.forEach { node in
            let snap = UISnapBehavior(item: node, snapTo: target)
            snap.damping = 0.6
            // Auto-remove so objects can fall away again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self, weak snap] in
                if let snap { self?.animator?.removeBehavior(snap) }
            }
            animator.addBehavior(snap)
        }
    }

    // MARK: - Gestures

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        onObjectTapped?(point)
        addNode(at: point)
    }

    private var dragAttachment: UIAttachmentBehavior?
    private var draggedNode: PhysicsNode?

    @objc private func handleDrag(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self)
        switch recognizer.state {
        case .began:
            if let hit = nodes.first(where: { $0.frame.contains(point) }) {
                draggedNode = hit
                let attachment = UIAttachmentBehavior(item: hit, attachedToAnchor: point)
                attachment.length = 0
                attachment.damping = 0.8
                attachment.frequency = 5.0
                dragAttachment = attachment
                animator.addBehavior(attachment)
            }
        case .changed:
            dragAttachment?.anchorPoint = point
        case .ended, .cancelled:
            if let att = dragAttachment { animator.removeBehavior(att) }
            dragAttachment = nil
            draggedNode = nil
        default: break
        }
    }
}

// MARK: - UIDynamicAnimatorDelegate

extension PhysicsCanvas: UIDynamicAnimatorDelegate {
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        onStatsUpdate?(nodes.count, false)
    }

    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        onStatsUpdate?(nodes.count, true)
    }
}
