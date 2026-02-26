import GoogleMobileAds
import Observation
import UIKit

@Observable
final class AdManager: NSObject {
    static let shared = AdManager()

    let bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
    let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"

    private var interstitialAd: GADInterstitialAd?

    private override init() {
        super.init()
    }

    /// Call from app launch to initialize the ads SDK.
    func configure() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        Task { await loadInterstitial() }
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
