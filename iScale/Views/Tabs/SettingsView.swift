import SwiftUI

struct SettingsView: View {
    @AppStorage(AppSettings.Keys.unitSystem) private var unitSystem = AppSettings.Defaults.unitSystem
    @AppStorage(AppSettings.Keys.hapticFeedback) private var hapticFeedback = AppSettings.Defaults.hapticFeedback
    @State private var apiKey: String = APIKeyStore.openAIKey ?? ""
    @State private var apiKeySaved = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("OpenAI API Key", text: $apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit { saveAPIKey() }

                    Button {
                        saveAPIKey()
                    } label: {
                        HStack {
                            Text("Save API Key")
                            Spacer()
                            if apiKeySaved {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .disabled(apiKey.isEmpty)
                } header: {
                    Text("AI Configuration")
                } footer: {
                    Text("Required for image analysis. Your key is stored securely in the device Keychain.")
                }

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
    private func saveAPIKey() {
        APIKeyStore.openAIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        apiKeySaved = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run { apiKeySaved = false }
        }
    }
}

#Preview {
    SettingsView()
}
