import Foundation

/// AdMob integration manager stub.
/// Replace with real Google Mobile Ads SDK initialization.
final class AdManager {
    static let shared = AdManager()

    // TODO: Replace with real Ad Unit IDs
    let bannerAdUnitID = "ca-app-pub-xxxxx/xxxxx"
    let interstitialAdUnitID = "ca-app-pub-xxxxx/xxxxx"

    private init() {}

    /// Call from app launch to initialize the ads SDK.
    func configure() {
        // TODO: GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    /// Show an interstitial ad if one is loaded.
    func showInterstitial() {
        // TODO: Present loaded interstitial
    }
}
