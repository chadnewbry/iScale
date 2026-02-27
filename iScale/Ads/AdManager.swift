import AppTrackingTransparency
import GoogleMobileAds
import Observation
import UIKit

@Observable
final class AdManager: NSObject {
    static let shared = AdManager()

    // MARK: - Ad Unit IDs
    let bannerAdUnitID = "ca-app-pub-7547154525975037/6739418996"
    let interstitialAdUnitID = "ca-app-pub-7547154525975037/1191074264"

    private var interstitialAd: GADInterstitialAd?

    private override init() {
        super.init()
    }

    /// Call from app launch to initialize the ads SDK and request ATT.
    func configure() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        requestTrackingAuthorization()
        Task { await loadInterstitial() }
    }

    // MARK: - App Tracking Transparency

    private func requestTrackingAuthorization() {
        // ATT must be requested after the app becomes active and the UI is visible.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                // ATT status received
            }
        }
    }

    // MARK: - Interstitial

    func loadInterstitial() async {
        do {
            interstitialAd = try await GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: GADRequest())
        } catch {
            // Interstitial load failed; will retry on next request
        }
    }

    /// Show an interstitial ad if one is loaded and user is not pro.
    func showInterstitial() {
        guard !StoreManager.shared.isProUser else { return }
        guard let ad = interstitialAd else {
            Task { await loadInterstitial() }
            return
        }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            ad.present(fromRootViewController: root)
        }

        // Preload next one
        Task { await loadInterstitial() }
    }
}
