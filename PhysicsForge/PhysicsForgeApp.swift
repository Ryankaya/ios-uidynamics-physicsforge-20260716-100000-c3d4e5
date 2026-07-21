import SwiftUI

@main
struct PhysicsForgeApp: App {
    @StateObject private var metricsViewModel = MetricsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(metricsViewModel)
        }
    }
}
