import UIKit

/// Shared service for analyzing images via OpenAI Vision API.
/// This is a stub — replace the placeholder with real API calls.
final class VisionService {
    static let shared = VisionService()

    private let apiKey: String? = nil // TODO: Load from secure storage

    private init() {}

    /// Analyze an image and return a description or measurement result.
    func analyzeImage(_ image: UIImage) async -> String {
        // TODO: Implement actual OpenAI Vision API call
        // 1. Convert image to base64
        // 2. Send to /v1/chat/completions with vision model
        // 3. Parse response for weight/scale reading

        // Stub delay to simulate network call
        try? await Task.sleep(for: .seconds(1))
        return "— Ready to analyze (API not configured)"
    }

    /// Convert a UIImage to a base64-encoded JPEG string.
    func imageToBase64(_ image: UIImage, quality: CGFloat = 0.8) -> String? {
        image.jpegData(compressionQuality: quality)?.base64EncodedString()
    }
}
