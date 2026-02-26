import SwiftUI
import StoreKit
import MessageUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings = SettingsManager.shared

    @State private var showShareSheet = false
    @State private var showMailCompose = false

    // TODO: Replace with actual URLs once deployed
    private let privacyPolicyURL = URL(string: "https://chadnewbry.github.io/iScale/privacy")!
    private let termsOfUseURL = URL(string: "https://chadnewbry.github.io/iScale/terms")!
    private let appStoreURL = URL(string: "https://apps.apple.com/app/iscale/id000000000")! // TODO: Replace with real ID

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        unitSystemSection
                        Divider().overlay(Color.gray.opacity(0.3))
                        settingsRow(title: "Feedback", icon: "envelope") {
                            sendFeedback()
                        }
                        Divider().overlay(Color.gray.opacity(0.3))
                        settingsRow(title: "Rate Us", icon: "star") {
                            requestReview()
                        }
                        Divider().overlay(Color.gray.opacity(0.3))
                        settingsRow(title: "Share", icon: "square.and.arrow.up") {
                            showShareSheet = true
                        }
                        Divider().overlay(Color.gray.opacity(0.3))
                        settingsRow(title: "Privacy Policy", icon: "lock.shield") {
                            openURL(privacyPolicyURL)
                        }
                        Divider().overlay(Color.gray.opacity(0.3))
                        settingsRow(title: "Terms of Use", icon: "doc.text") {
                            openURL(termsOfUseURL)
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [appStoreURL])
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Unit System Section

    private var unitSystemSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "ruler")
                    .foregroundStyle(.cyan)
                    .frame(width: 28)
                Text("Unit System")
                    .foregroundStyle(.white)
            }
            .font(.body)
            .padding(.horizontal, 20)

            Picker("Unit System", selection: $settings.unitSystem) {
                ForEach(UnitSystem.allCases, id: \.self) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .tint(.cyan)
        }
        .padding(.vertical, 16)
    }

    // MARK: - Row Builder

    private func settingsRow(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.cyan)
                    .frame(width: 28)
                Text(title)
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .font(.body)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func sendFeedback() {
        let email = "feedback@iscaleapp.com" // TODO: Replace with real email
        if let url = URL(string: "mailto:\(email)?subject=iScale%20Feedback") {
            UIApplication.shared.open(url)
        }
    }

    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
}
