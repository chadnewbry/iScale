import SwiftUI

struct SettingsView: View {
    @AppStorage(AppSettings.Keys.unitSystem) private var unitSystem = AppSettings.Defaults.unitSystem
    @AppStorage(AppSettings.Keys.hapticFeedback) private var hapticFeedback = AppSettings.Defaults.hapticFeedback

    var body: some View {
        NavigationStack {
            Form {
                Section("Units") {
                    Picker("Unit System", selection: $unitSystem) {
                        Text("Metric (kg)").tag("metric")
                        Text("Imperial (lb)").tag("imperial")
                    }
                }

                Section("Preferences") {
                    Toggle("Haptic Feedback", isOn: $hapticFeedback)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
