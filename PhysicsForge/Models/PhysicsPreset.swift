import Foundation

enum ScenePreset: String, CaseIterable, Identifiable {
    case pendulum      = "Pendulum"
    case newtonsCradle = "Newton's Cradle"
    case avalanche     = "Avalanche"
    case springNetwork = "Spring Network"
    case orbits        = "Orbits"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .pendulum:
            return "UIAttachmentBehavior spring + UIGravityBehavior"
        case .newtonsCradle:
            return "Momentum transfer via collision + attachments"
        case .avalanche:
            return "Pyramid collapse under UIGravityBehavior"
        case .springNetwork:
            return "UIAttachmentBehavior frequency + damping mesh"
        case .orbits:
            return "Tangential UIPushBehavior + radial attachment"
        }
    }

    var description: String {
        switch self {
        case .pendulum:
            return "A ball swings from a fixed anchor point, driven by gravity and a spring-like attachment with configurable length, damping, and frequency."
        case .newtonsCradle:
            return "Five equal-mass balls suspended by spring attachments. Push the first ball to observe momentum and energy transfer through the chain."
        case .avalanche:
            return "A pyramid of stacked blocks. Tap any block to remove it and watch the avalanche unfold under gravity and collision dynamics."
        case .springNetwork:
            return "A grid of balls interconnected by spring attachments. Drag any node to distort the network and watch oscillations propagate."
        case .orbits:
            return "Balls pinned at a fixed radius from the center via attachments, launched with tangential velocity to maintain orbital paths."
        }
    }

    var systemImage: String {
        switch self {
        case .pendulum:      return "timer"
        case .newtonsCradle: return "equal.circle"
        case .avalanche:     return "square.stack.3d.down.right.fill"
        case .springNetwork: return "circle.grid.3x3.fill"
        case .orbits:        return "circles.hexagongrid.fill"
        }
    }

    var accentColorName: String {
        switch self {
        case .pendulum:      return "coral"
        case .newtonsCradle: return "steel"
        case .avalanche:     return "amber"
        case .springNetwork: return "teal"
        case .orbits:        return "sky"
        }
    }
}
