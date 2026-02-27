import SwiftUI
import StoreKit
import MessageUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings = SettingsManager.shared

    @State private var showShareSheet = false
    @State private var showMailCompose = false
    @State private var isPurchasing = false
    @State private var isRestoring = false

    private let privacyPolicyURL = URL(string: "https://chadnewbry.github.io/iScale/privacy")!
    private let termsOfUseURL = URL(string: "https://chadnewbry.github.io/iScale/terms")!
    private let appStoreURL = URL(string: "https://chadnewbry.github.io/iScale/")!

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        removeAdsSection
                        Divider().overlay(Color.gray.opacity(0.3))
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
            .sheet(isPresented: $showMailCompose) {
                MailComposeView(
                    recipients: ["chad.newbry@gmail.com"],
                    subject: "iScale Feedback"
                )
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Remove Ads Section

    private var removeAdsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if StoreManager.shared.isProUser {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .frame(width: 28)
                    Text("Ads Removed")
                        .foregroundStyle(.white)
                }
                .font(.body)
                .padding(.horizontal, 20)
            } else {
                Button {
                    isPurchasing = true
                    Task {
                        do { try await StoreManager.shared.purchase() }
                        catch { /* Purchase failed or cancelled */ }
                        await MainActor.run { isPurchasing = false }
                    }
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(.cyan)
                            .frame(width: 28)
                        Text("Remove Ads")
                            .foregroundStyle(.white)
                        Spacer()
                        if isPurchasing {
                            ProgressView()
                                .tint(.cyan)
                        } else if let product = StoreManager.shared.removeAdsProduct {
                            Text(product.displayPrice)
                                .foregroundStyle(.gray)
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .font(.body)
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isPurchasing)

                Divider().overlay(Color.gray.opacity(0.3)).padding(.leading, 68)

                Button {
                    isRestoring = true
                    Task {
                        await StoreManager.shared.restorePurchases()
                        await MainActor.run { isRestoring = false }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(.cyan)
                            .frame(width: 28)
                        Text("Restore Purchases")
                            .foregroundStyle(.white)
                        Spacer()
                        if isRestoring {
                            ProgressView()
                                .tint(.cyan)
                        }
                    }
                    .font(.body)
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isRestoring)
            }
        }
        .padding(.vertical, 16)
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
        if MFMailComposeViewController.canSendMail() {
            showMailCompose = true
        } else if let url = URL(string: "mailto:chad.newbry@gmail.com?subject=iScale%20Feedback") {
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

// MARK: - Mail Compose

struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let recipients: [String]
    let subject: String

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        init(_ parent: MailComposeView) { self.parent = parent }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

#Preview {
    SettingsView()
}
