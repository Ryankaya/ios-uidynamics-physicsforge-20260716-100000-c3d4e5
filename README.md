# PhysicsForge

An interactive iOS physics sandbox demonstrating **UIKit Dynamics** — Apple's high-level physics simulation framework built on the Bullet physics engine.

## Feature: UIKit Dynamics (UIDynamicAnimator)

UIKit Dynamics allows any `UIView` to participate in a physics simulation via `UIDynamicAnimator`. Objects become physical bodies governed by gravity, collision, spring forces, and more — all coordinated by a reference `UIView`.

## APIs Demonstrated

| API | Usage in App |
|-----|-------------|
| `UIDynamicAnimator` | Main physics coordinator; `UIDynamicAnimatorDelegate` for pause/resume events |
| `UIGravityBehavior` | 7 gravity presets: Earth/Moon/Mars/Zero-G/Inverted/Sideways — live switchable |
| `UICollisionBehavior` | Boundary collision via `translatesReferenceBoundsIntoBoundary`; per-object shape |
| `UIDynamicItemBehavior` | Per-object `elasticity`, `friction`, `density`, `angularResistance`, `allowsRotation` |
| `UIAttachmentBehavior` | Spring attachments with `frequency`, `damping`, `length` — pendulum & spring network |
| `UISnapBehavior` | Snap-to-center with configurable `damping` |
| `UIPushBehavior` | `.instantaneous` forces for shake, orbital tangential launch |
| `UIDynamicItem` protocol | Custom `UIView` subclass overriding `collisionBoundsType` (.ellipse for circles) |
| `collisionBoundingPath` | Triangle custom UIBezierPath collision shape |
| Drag via `UIAttachmentBehavior` | Pan gesture creates a real-time spring to the finger |

## Apple Documentation

- [UIKit Dynamics – UIKit Documentation](https://developer.apple.com/documentation/uikit/animation_and_haptics/uikit_dynamics)
- [UIDynamicAnimator](https://developer.apple.com/documentation/uikit/uidynamicanimator)
- [UIAttachmentBehavior](https://developer.apple.com/documentation/uikit/uiattachmentbehavior)
- [UIGravityBehavior](https://developer.apple.com/documentation/uikit/uigravitybehavior)
- [UICollisionBehavior](https://developer.apple.com/documentation/uikit/uicollisionbehavior)
- [UIDynamicItemBehavior](https://developer.apple.com/documentation/uikit/uidynamicitembehavior)
- [UIPushBehavior](https://developer.apple.com/documentation/uikit/uipushbehavior)
- [UISnapBehavior](https://developer.apple.com/documentation/uikit/uisnapbehavior)

## App Structure (4-tab MVVM)

```
Sandbox ── Free-play physics canvas
           Tap to spawn objects (4 shapes × 6 colors × 5 materials)
           7 gravity presets, shake, clear, drag nodes
Scenes  ── 5 preset physics demonstrations
           • Pendulum (spring + gravity)
           • Newton's Cradle (momentum transfer)
           • Avalanche (pyramid collapse)
           • Spring Network (interconnected mesh)
           • Orbits (tangential push + attachment)
Lab     ── Fine-tune gravity magnitude/angle, elasticity, friction,
           density, angular resistance with live ball preview
Metrics ── Session stats: spawn count, shape distribution,
           material usage, gravity preset frequency
```

## Architecture

- **Models**: Value-type structs/enums (`PhysicsShape`, `GravityPreset`, `PhysicsMaterialPreset`, `ScenePreset`, `SessionStats`)
- **ViewModels**: `@MainActor` `ObservableObject` classes with `@Published` state
- **UIKit Layer**: `PhysicsCanvas` (UIView + UIDynamicAnimator) wrapped via `UIViewRepresentable`
- **Scene Layer**: `SceneCanvas` (UIView) with preset-specific physics setup routines

## Requirements

- iOS 16.2+
- Xcode 15+
- Swift 5.9
