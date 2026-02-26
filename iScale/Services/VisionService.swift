import UIKit

/// Errors that can occur during vision analysis.
enum VisionServiceError: LocalizedError {
    case noAPIKey
    case imageConversionFailed
    case networkError(Error)
    case rateLimited(retryAfter: Int?)
    case invalidResponse(String)
    case serverError(Int, String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "OpenAI API key not configured. Please add your API key in Settings."
        case .imageConversionFailed:
            return "Failed to process the image. Please try again."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Too many requests. Please wait \(seconds) seconds and try again."
            }
            return "Too many requests. Please wait a moment and try again."
        case .invalidResponse(let detail):
            return "Unexpected response from AI service. \(detail)"
        case .serverError(let code, _):
            return "Server error (\(code)). Please try again later."
        }
    }
}

/// Structured response from the Vision API, parsed per-mode.
struct VisionAnalysis {
    let title: String
    let value: String
    let detail: String
    let explanation: String
    let raw: String
}

/// Shared service for analyzing images via OpenAI's Vision API.
final class VisionService {
    static let shared = VisionService()

    private let session: URLSession
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let model = "gpt-4o-mini"

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public API

    /// Analyze an image for the given mode.
    /// Returns a user-friendly result string on success, or throws a VisionServiceError.
    func analyzeImage(_ image: UIImage?, mode: AppMode = .digitalScale) async -> String {
        do {
            let analysis = try await analyze(image: image, mode: mode)
            return analysis.value
        } catch let error as VisionServiceError {
            return "⚠️ \(error.localizedDescription)"
        } catch {
            return "⚠️ Something went wrong. Please try again."
        }
    }

    /// Full structured analysis — use this when you need all fields.
    func analyze(image: UIImage?, mode: AppMode) async throws -> VisionAnalysis {
        guard let apiKey = APIKeyStore.openAIKey, !apiKey.isEmpty else {
            throw VisionServiceError.noAPIKey
        }

        guard let image, let base64 = imageToBase64(image) else {
            throw VisionServiceError.imageConversionFailed
        }

        let body = buildRequestBody(base64: base64, mode: mode)
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw VisionServiceError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw VisionServiceError.invalidResponse("No HTTP response")
        }

        if http.statusCode == 429 {
            let retry = http.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
            throw VisionServiceError.rateLimited(retryAfter: retry)
        }

        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw VisionServiceError.serverError(http.statusCode, body)
        }

        return try parseResponse(data: data, mode: mode)
    }

    // MARK: - Private

    private func imageToBase64(_ image: UIImage, quality: CGFloat = 0.7) -> String? {
        // Downscale large images to save tokens
        let maxDimension: CGFloat = 1024
        let scaled = image.preparingThumbnail(of: targetSize(for: image.size, max: maxDimension)) ?? image
        return scaled.jpegData(compressionQuality: quality)?.base64EncodedString()
    }

    private func targetSize(for size: CGSize, max: CGFloat) -> CGSize {
        guard size.width > max || size.height > max else { return size }
        let ratio = min(max / size.width, max / size.height)
        return CGSize(width: size.width * ratio, height: size.height * ratio)
    }

    private func buildRequestBody(base64: String, mode: AppMode) -> [String: Any] {
        [
            "model": model,
            "max_tokens": 500,
            "messages": [
                [
                    "role": "system",
                    "content": mode.systemPrompt
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64)",
                                "detail": "low"
                            ]
                        ] as [String: Any],
                        [
                            "type": "text",
                            "text": mode.userPrompt
                        ]
                    ]
                ]
            ]
        ]
    }

    private func parseResponse(data: Data, mode: AppMode) throws -> VisionAnalysis {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw VisionServiceError.invalidResponse("Could not extract content from response.")
        }

        // Try to parse as JSON first, fall back to raw text
        if let jsonData = content.data(using: .utf8),
           let parsed = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            return VisionAnalysis(
                title: parsed["title"] as? String ?? mode.rawValue,
                value: parsed["value"] as? String ?? content,
                detail: parsed["detail"] as? String ?? "",
                explanation: parsed["explanation"] as? String ?? "",
                raw: content
            )
        }

        // Plain text fallback
        return VisionAnalysis(
            title: mode.rawValue,
            value: content.trimmingCharacters(in: .whitespacesAndNewlines),
            detail: "",
            explanation: "",
            raw: content
        )
    }
}
