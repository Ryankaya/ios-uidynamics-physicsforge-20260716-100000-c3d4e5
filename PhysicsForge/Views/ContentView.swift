import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SandboxView()
                .tabItem { Label("Sandbox", systemImage: "hand.tap.fill") }

            ScenesView()
                .tabItem { Label("Scenes", systemImage: "play.rectangle.fill") }

            LabView()
                .tabItem { Label("Lab", systemImage: "slider.horizontal.3") }

            MetricsView()
                .tabItem { Label("Metrics", systemImage: "chart.bar.fill") }
        }
    }
}
