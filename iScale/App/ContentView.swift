import SwiftUI

struct ContentView: View {
    @AppStorage(AppSettings.Keys.onboardingComplete) private var onboardingComplete = AppSettings.Defaults.onboardingComplete
    @State private var selectedTab: AppTab = .camera

    var body: some View {
        if onboardingComplete {
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
        } else {
            UnitPickerOnboardingView()
        }
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
