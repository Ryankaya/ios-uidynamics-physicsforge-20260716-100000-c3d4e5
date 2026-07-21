import UIKit
import SwiftUI

// MARK: - Shape

enum PhysicsShape: String, CaseIterable, Codable, Identifiable {
    case circle, square, triangle, hexagon

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .circle:   return "Circle"
        case .square:   return "Square"
        case .triangle: return "Triangle"
        case .hexagon:  return "Hexagon"
        }
    }

    var systemImage: String {
        switch self {
        case .circle:   return "circle.fill"
        case .square:   return "square.fill"
        case .triangle: return "triangle.fill"
        case .hexagon:  return "hexagon.fill"
        }
    }

    // UIKit Dynamics uses rectangular bounds by default.
    // Circle and hexagon get ellipse-based collision for accuracy.
    var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        switch self {
        case .circle, .hexagon: return .ellipse
        case .square, .triangle: return .rectangle
        }
    }
}

// MARK: - Color

enum PhysicsColor: String, CaseIterable, Codable, Identifiable {
    case coral, teal, purple, amber, lime, sky

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var uiColor: UIColor {
        switch self {
        case .coral:  return UIColor(red: 0.96, green: 0.36, blue: 0.26, alpha: 1)
        case .teal:   return UIColor(red: 0.22, green: 0.72, blue: 0.72, alpha: 1)
        case .purple: return UIColor(red: 0.60, green: 0.28, blue: 0.80, alpha: 1)
        case .amber:  return UIColor(red: 1.00, green: 0.76, blue: 0.03, alpha: 1)
        case .lime:   return UIColor(red: 0.40, green: 0.80, blue: 0.20, alpha: 1)
        case .sky:    return UIColor(red: 0.24, green: 0.60, blue: 1.00, alpha: 1)
        }
    }

    var swiftUIColor: Color { Color(uiColor: uiColor) }
}

// MARK: - Material

enum PhysicsMaterialPreset: String, CaseIterable, Codable, Identifiable {
    case rubber, steel, wood, glass, balloon

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }

    var systemImage: String {
        switch self {
        case .rubber:  return "circle.dotted"
        case .steel:   return "bolt.shield.fill"
        case .wood:    return "leaf.fill"
        case .glass:   return "sparkles"
        case .balloon: return "airballoon.fill"
        }
    }

    var elasticity: CGFloat {
        switch self {
        case .rubber:  return 0.85
        case .steel:   return 0.20
        case .wood:    return 0.40
        case .glass:   return 0.65
        case .balloon: return 0.90
        }
    }

    var friction: CGFloat {
        switch self {
        case .rubber:  return 0.60
        case .steel:   return 0.20
        case .wood:    return 0.70
        case .glass:   return 0.10
        case .balloon: return 0.05
        }
    }

    var density: CGFloat {
        switch self {
        case .rubber:  return 1.0
        case .steel:   return 4.0
        case .wood:    return 1.5
        case .glass:   return 0.8
        case .balloon: return 0.1
        }
    }

    var angularResistance: CGFloat {
        switch self {
        case .rubber:  return 0.20
        case .steel:   return 0.50
        case .wood:    return 0.35
        case .glass:   return 0.10
        case .balloon: return 0.02
        }
    }
}

// MARK: - Gravity

enum GravityPreset: String, CaseIterable, Identifiable, Codable {
    case earth, moon, mars, zero, inverted, sidewaysRight, sidewaysLeft

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .earth:         return "Earth"
        case .moon:          return "Moon"
        case .mars:          return "Mars"
        case .zero:          return "Zero-G"
        case .inverted:      return "Inverted"
        case .sidewaysRight: return "Sideways →"
        case .sidewaysLeft:  return "Sideways ←"
        }
    }

    var systemImage: String {
        switch self {
        case .earth:         return "globe"
        case .moon:          return "moon.fill"
        case .mars:          return "globe.europe.africa.fill"
        case .zero:          return "star.fill"
        case .inverted:      return "arrow.up"
        case .sidewaysRight: return "arrow.right"
        case .sidewaysLeft:  return "arrow.left"
        }
    }

    var description: String {
        switch self {
        case .earth:         return "Standard 9.8 m/s²"
        case .moon:          return "Lunar 1.62 m/s²"
        case .mars:          return "Martian 3.72 m/s²"
        case .zero:          return "Microgravity environment"
        case .inverted:      return "Falling toward the ceiling"
        case .sidewaysRight: return "Horizontal rightward field"
        case .sidewaysLeft:  return "Horizontal leftward field"
        }
    }

    var magnitude: CGFloat {
        switch self {
        case .earth:                    return 1.00
        case .moon:                     return 0.165
        case .mars:                     return 0.376
        case .zero:                     return 0.00
        case .inverted:                 return 1.00
        case .sidewaysRight, .sidewaysLeft: return 1.00
        }
    }

    // In UIDynamicAnimator +Y is downward on screen
    var gravityDirection: CGVector {
        switch self {
        case .earth:         return CGVector(dx: 0,  dy:  magnitude)
        case .moon:          return CGVector(dx: 0,  dy:  magnitude)
        case .mars:          return CGVector(dx: 0,  dy:  magnitude)
        case .zero:          return CGVector(dx: 0,  dy:  0)
        case .inverted:      return CGVector(dx: 0,  dy: -magnitude)
        case .sidewaysRight: return CGVector(dx:  magnitude, dy: 0)
        case .sidewaysLeft:  return CGVector(dx: -magnitude, dy: 0)
        }
    }
}
