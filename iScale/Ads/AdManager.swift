import AppTrackingTransparency
import GoogleMobileAds
import Observation
import UIKit

@Observable
final class AdManager: NSObject {
    static let shared = AdManager()

    // MARK: - Ad Unit IDs
    // TODO: Replace with production ad unit IDs from AdMob dashboard before release
    let bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
    let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"

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
                print("ATT status: \(status.rawValue)")
            }
        }
    }

    // MARK: - Interstitial

    func loadInterstitial() async {
        do {
            interstitialAd = try await GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: GADRequest())
        } catch {
            print("Failed to load interstitial: \(error)")
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
