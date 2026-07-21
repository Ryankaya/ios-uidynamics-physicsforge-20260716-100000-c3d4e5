import SwiftUI

struct SandboxView: View {
    @EnvironmentObject var metricsVM: MetricsViewModel
    @StateObject private var viewModel = SandboxViewModel()
    @State private var showControls = true

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Status bar
                    statusBar

                    // Physics canvas fills available space
                    PhysicsCanvasRepresentable(viewModel: viewModel)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(.systemFill), lineWidth: 1)
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)

                    // Controls
                    if showControls {
                        controlPanel
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Sandbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.spring(response: 0.35)) { showControls.toggle() }
                    } label: {
                        Image(systemName: showControls ? "chevron.down.circle" : "chevron.up.circle")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { viewModel.shake() } label: {
                        Image(systemName: "waveform")
                    }
                    Button { viewModel.clearAll() } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
            }
        }
        .onAppear {
            viewModel.metricsViewModel = metricsVM
        }
    }

    // MARK: - Status bar

    private var statusBar: some View {
        HStack(spacing: 20) {
            Label("\(viewModel.objectCount)", systemImage: "cube.fill")
                .font(.caption.bold())
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(viewModel.isSimulating ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(viewModel.isSimulating ? "Simulating" : "Paused")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Label(viewModel.gravityPreset.displayName, systemImage: viewModel.gravityPreset.systemImage)
                .font(.caption.bold())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
    }

    // MARK: - Control panel

    private var controlPanel: some View {
        VStack(spacing: 12) {
            // Shape row
            HStack(spacing: 0) {
                ForEach(PhysicsShape.allCases) { shape in
                    Button {
                        viewModel.selectedShape = shape
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: shape.systemImage)
                                .font(.title3)
                            Text(shape.displayName)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedShape == shape
                            ? Color.accentColor.opacity(0.15) : Color.clear
                        )
                        .foregroundStyle(
                            viewModel.selectedShape == shape
                            ? Color.accentColor : Color.primary
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 12)

            // Color + Material row
            HStack(spacing: 10) {
                // Color picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PhysicsColor.allCases) { c in
                            Circle()
                                .fill(c.swiftUIColor)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: viewModel.selectedColor == c ? 3 : 0)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                                .scaleEffect(viewModel.selectedColor == c ? 1.15 : 1)
                                .animation(.spring(response: 0.25), value: viewModel.selectedColor)
                                .onTapGesture { viewModel.selectedColor = c }
                        }
                    }
                    .padding(.horizontal, 4)
                }

                Divider().frame(height: 36)

                // Material picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(PhysicsMaterialPreset.allCases) { mat in
                            Button {
                                viewModel.selectedMaterial = mat
                            } label: {
                                VStack(spacing: 2) {
                                    Image(systemName: mat.systemImage)
                                        .font(.caption)
                                    Text(mat.displayName)
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(
                                    viewModel.selectedMaterial == mat
                                    ? Color.accentColor : Color(.tertiarySystemBackground)
                                )
                                .foregroundStyle(
                                    viewModel.selectedMaterial == mat ? .white : .primary
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .frame(height: 48)
            .padding(.horizontal, 12)

            // Gravity row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GravityPreset.allCases) { preset in
                        Button {
                            viewModel.gravityChanged(to: preset)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: preset.systemImage)
                                    .font(.caption)
                                Text(preset.displayName)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                viewModel.gravityPreset == preset
                                ? Color.accentColor : Color(.tertiarySystemBackground)
                            )
                            .foregroundStyle(
                                viewModel.gravityPreset == preset ? .white : .primary
                            )
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}
