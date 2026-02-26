import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView()
        banner.adUnitID = AdManager.shared.bannerAdUnitID
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            banner.rootViewController = root
        }
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

#Preview {
    BannerAdView()
        .frame(height: 50)
}
