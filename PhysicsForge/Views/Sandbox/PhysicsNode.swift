import UIKit

// PhysicsNode is a UIView subclass that serves as a UIDynamicItem.
// It overrides collisionBoundsType so circles get ellipse-based collisions.
final class PhysicsNode: UIView {

    let shape: PhysicsShape
    let nodeColor: UIColor

    private static let sizes: ClosedRange<CGFloat> = 30...62

    init(shape: PhysicsShape, color: UIColor, at center: CGPoint) {
        self.shape = shape
        self.nodeColor = color
        let size = CGFloat.random(in: Self.sizes)
        super.init(frame: CGRect(x: center.x - size / 2,
                                 y: center.y - size / 2,
                                 width: size, height: size))
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UIDynamicItem conformance

    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        shape.collisionBoundsType
    }

    // For path-based collision (triangle), provide a custom bounding path
    override var collisionBoundingPath: UIBezierPath {
        switch shape {
        case .triangle:
            let path = UIBezierPath()
            let r = bounds
            path.move(to: CGPoint(x: r.midX, y: r.minY))
            path.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
            path.addLine(to: CGPoint(x: r.minX, y: r.maxY))
            path.close()
            return path
        default:
            return super.collisionBoundingPath
        }
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let inset: CGFloat = 2
        let r = rect.insetBy(dx: inset, dy: inset)

        // Drop shadow
        ctx.setShadow(offset: CGSize(width: 0, height: 3),
                      blur: 6,
                      color: UIColor.black.withAlphaComponent(0.25).cgColor)

        ctx.setFillColor(nodeColor.cgColor)

        switch shape {
        case .circle, .hexagon:
            ctx.fillEllipse(in: r)
            // Specular highlight
            ctx.setShadow(offset: .zero, blur: 0, color: UIColor.clear.cgColor)
            ctx.setFillColor(UIColor.white.withAlphaComponent(0.30).cgColor)
            let hSize = r.width * 0.38
            ctx.fillEllipse(in: CGRect(x: r.minX + 6, y: r.minY + 5, width: hSize, height: hSize * 0.7))

        case .square:
            let path = UIBezierPath(roundedRect: r, cornerRadius: 7)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            ctx.setShadow(offset: .zero, blur: 0, color: UIColor.clear.cgColor)
            ctx.setFillColor(UIColor.white.withAlphaComponent(0.22).cgColor)
            let hPath = UIBezierPath(roundedRect: CGRect(x: r.minX + 5, y: r.minY + 5,
                                                          width: r.width * 0.45,
                                                          height: r.height * 0.35), cornerRadius: 3)
            ctx.addPath(hPath.cgPath)
            ctx.fillPath()

        case .triangle:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: r.midX, y: r.minY))
            path.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
            path.addLine(to: CGPoint(x: r.minX, y: r.maxY))
            path.close()
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        }
    }
}
