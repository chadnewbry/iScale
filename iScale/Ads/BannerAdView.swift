import SwiftUI

/// AdMob banner ad stub.
/// Replace with real Google Mobile Ads SDK integration.
struct BannerAdView: View {
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray6))
            .overlay(
                Text("Ad Space")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            )
    }
}

#Preview {
    BannerAdView()
        .frame(height: 50)
}
