import SwiftUI

struct MetricsView: View {
    @EnvironmentObject var viewModel: MetricsViewModel

    var body: some View {
        NavigationView {
            List {
                // Summary
                Section("Session") {
                    statRow("Duration", value: viewModel.stats.formattedDuration, icon: "clock")
                    statRow("Total Spawned", value: "\(viewModel.stats.totalSpawned)", icon: "cube.fill")
                    statRow("Current Objects", value: "\(viewModel.stats.currentObjectCount)", icon: "square.3.layers.3d")
                    statRow("Shakes", value: "\(viewModel.stats.shakeCount)", icon: "waveform")
                    statRow("Clears", value: "\(viewModel.stats.clearCount)", icon: "trash")
                    statRow("Pauses", value: "\(viewModel.stats.pauseCount)", icon: "pause.circle")
                }

                // Shape distribution
                if viewModel.stats.totalSpawned > 0 {
                    Section("Shape Distribution") {
                        ForEach(viewModel.shapeDistribution, id: \.shape) { item in
                            shapeRow(item.shape, count: item.count, total: viewModel.stats.totalSpawned)
                        }
                    }

                    // Material usage (only show materials that were used)
                    let usedMaterials = PhysicsMaterialPreset.allCases.filter {
                        viewModel.stats.materialCounts[$0, default: 0] > 0
                    }
                    if !usedMaterials.isEmpty {
                        Section("Material Usage") {
                            ForEach(usedMaterials, id: \.self) { mat in
                                HStack {
                                    Image(systemName: mat.systemImage)
                                        .foregroundColor(.accentColor)
                                        .frame(width: 28)
                                    Text(mat.displayName)
                                    Spacer()
                                    Text("\(viewModel.stats.materialCounts[mat, default: 0])")
                                        .monospacedDigit()
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                // Gravity usage
                if !viewModel.topGravityPresets.isEmpty {
                    Section("Gravity Presets Used") {
                        ForEach(viewModel.topGravityPresets, id: \.preset) { item in
                            HStack {
                                Image(systemName: item.preset.systemImage)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.preset.displayName)
                                    Text(item.preset.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(item.count)×")
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Empty state hint
                if viewModel.stats.totalSpawned == 0 {
                    Section {
                        VStack(spacing: 10) {
                            Image(systemName: "cube.transparent")
                                .font(.system(size: 42))
                                .foregroundStyle(.tertiary)
                            Text("Head to Sandbox")
                                .font(.headline)
                            Text("Tap the canvas to spawn physics objects. Stats appear here as you interact.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Metrics")
        }
    }

    // MARK: - Helpers

    private func statRow(_ label: String, value: String, icon: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            Text(value)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }

    private func shapeRow(_ shape: PhysicsShape, count: Int, total: Int) -> some View {
        VStack(spacing: 6) {
            HStack {
                Label(shape.displayName, systemImage: shape.systemImage)
                Spacer()
                Text("\(count)")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color(.systemFill)).frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.accentColor)
                        .frame(width: total > 0 ? geo.size.width * CGFloat(count) / CGFloat(total) : 0, height: 5)
                }
            }
            .frame(height: 5)
        }
        .padding(.vertical, 4)
    }
}
