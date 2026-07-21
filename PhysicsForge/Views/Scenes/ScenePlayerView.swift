import SwiftUI

struct SceneCanvasRepresentable: UIViewRepresentable {
    let preset: ScenePreset
    let triggerReset: Bool

    func makeUIView(context: Context) -> SceneCanvas {
        let canvas = SceneCanvas()
        return canvas
    }

    func updateUIView(_ canvas: SceneCanvas, context: Context) {
        // Load preset once layout is available; repeat on triggerReset toggle
        if canvas.bounds.width > 0 {
            canvas.loadPreset(preset)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                canvas.loadPreset(preset)
            }
        }
    }
}

struct ScenePlayerView: View {
    let preset: ScenePreset
    @Environment(\.dismiss) private var dismiss
    @State private var resetTrigger = false
    @State private var showInfo = true

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showInfo {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(preset.subtitle)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Text(preset.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                SceneCanvasRepresentable(preset: preset, triggerReset: resetTrigger)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.systemFill)))
                    .padding(12)
            }
            .background(Color(.systemBackground))
            .navigationTitle(preset.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3)) { showInfo.toggle() }
                    } label: {
                        Image(systemName: showInfo ? "info.circle.fill" : "info.circle")
                    }
                    Button {
                        resetTrigger.toggle()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct ScenesView: View {
    @StateObject private var viewModel = ScenesViewModel()
    @State private var selectedPreset: ScenePreset? = nil

    private let presetColors: [ScenePreset: Color] = [
        .pendulum:      .red,
        .newtonsCradle: .gray,
        .avalanche:     .orange,
        .springNetwork: .teal,
        .orbits:        .blue,
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(ScenePreset.allCases) { preset in
                    Button {
                        selectedPreset = preset
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill((presetColors[preset] ?? .accentColor).opacity(0.15))
                                    .frame(width: 52, height: 52)
                                Image(systemName: preset.systemImage)
                                    .font(.title2)
                                    .foregroundStyle(presetColors[preset] ?? .accentColor)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(preset.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(preset.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Scenes")
            .sheet(item: $selectedPreset) { preset in
                ScenePlayerView(preset: preset)
            }
        }
    }
}
