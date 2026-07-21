import SwiftUI

@MainActor
final class ScenesViewModel: ObservableObject {
    @Published var selectedPreset: ScenePreset? = nil
    @Published var isPlaying: Bool = false
    @Published var showDetail: Bool = false

    func select(_ preset: ScenePreset) {
        selectedPreset = preset
        isPlaying = false
        showDetail = true
    }

    func dismiss() {
        showDetail = false
        isPlaying = false
    }

    func togglePlayback() {
        isPlaying.toggle()
    }
}
