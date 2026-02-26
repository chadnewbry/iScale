import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .camera

    var body: some View {
        TabView(selection: $selectedTab) {
            CameraView()
                .tabItem {
                    Label("Scale", systemImage: "camera.fill")
                }
                .tag(AppTab.camera)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(AppTab.history)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(.black)
    }
}

enum AppTab: Hashable {
    case camera
    case history
    case settings
}

#Preview {
    ContentView()
}
