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

/// A single object weight estimate parsed from the Vision API.
struct ParsedWeightEstimate {
    let name: String
    let weight: String
    let unit: String
}

/// A single object dimension estimate parsed from the Vision API.
struct ParsedDimensionEstimate {
    let name: String
    let length: String
    let width: String
    let height: String
    let unit: String
}

/// A single food item calorie estimate parsed from the Vision API.
struct ParsedCalorieEstimate {
    let name: String
    let portion: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
}

/// A parsed translation result from the Vision API.
struct ParsedTranslationResult {
    let translatedText: String
    let sourceLanguage: String
    let translationNotes: String
}

/// A single object count parsed from the Vision API.
struct ParsedObjectCount {
    let name: String
    let count: Int
    let category: String
}

/// A single plant identification parsed from the Vision API.
struct ParsedPlantIdentification {
    let commonName: String
    let scientificName: String
    let description: String
    let confidence: String
}

/// Structured response from the Vision API, parsed per-mode.
struct VisionAnalysis {
    let title: String
    let value: String
    let detail: String
    let explanation: String
    let raw: String

    /// For Digital Scale mode: parsed individual object estimates.
    var weightEstimates: [ParsedWeightEstimate] = []

    /// For Tape Measure mode: parsed individual dimension estimates.
    var dimensionEstimates: [ParsedDimensionEstimate] = []

    /// For Calorie Counter mode: parsed individual food item estimates.
    var calorieEstimates: [ParsedCalorieEstimate] = []

    /// For Translate mode: parsed translation result.
    var translationResult: ParsedTranslationResult?
    /// For Plant Identifier mode: parsed individual plant identifications.
    var plantIdentifications: [ParsedPlantIdentification] = []

    /// For Object Counter mode: parsed individual object counts.
    var objectCounts: [ParsedObjectCount] = []
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
            "max_tokens": 800,
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

            // Digital Scale mode: parse multi-object response
            if mode == .digitalScale, let objects = parsed["objects"] as? [[String: Any]] {
                let estimates = objects.compactMap { obj -> ParsedWeightEstimate? in
                    guard let name = obj["name"] as? String,
                          let unit = obj["unit"] as? String else { return nil }
                    // weight can be String or Number
                    let weight: String
                    if let w = obj["weight"] as? String {
                        weight = w
                    } else if let w = obj["weight"] as? NSNumber {
                        weight = w.stringValue
                    } else {
                        return nil
                    }
                    return ParsedWeightEstimate(name: name, weight: weight, unit: unit)
                }

                let summary = estimates.map { "\($0.name): \($0.weight) \($0.unit)" }.joined(separator: ", ")
                let explanation = parsed["explanation"] as? String ?? ""

                return VisionAnalysis(
                    title: estimates.first?.name ?? "Digital Scale",
                    value: estimates.first.map { "\($0.weight) \($0.unit)" } ?? content,
                    detail: estimates.count > 1 ? "\(estimates.count) objects detected" : "",
                    explanation: explanation,
                    raw: content,
                    weightEstimates: estimates
                )
            }

            // Tape Measure mode: parse multi-object dimension response
            if mode == .tapeMeasure, let objects = parsed["objects"] as? [[String: Any]] {
                let estimates = objects.compactMap { obj -> ParsedDimensionEstimate? in
                    guard let name = obj["name"] as? String,
                          let unit = obj["unit"] as? String else { return nil }

                    func stringValue(_ key: String) -> String? {
                        if let s = obj[key] as? String { return s }
                        if let n = obj[key] as? NSNumber { return n.stringValue }
                        return nil
                    }

                    guard let length = stringValue("length"),
                          let width = stringValue("width"),
                          let height = stringValue("height") else { return nil }

                    return ParsedDimensionEstimate(name: name, length: length, width: width, height: height, unit: unit)
                }

                let explanation = parsed["explanation"] as? String ?? ""
                let firstEstimate = estimates.first

                return VisionAnalysis(
                    title: firstEstimate?.name ?? "Tape Measure",
                    value: firstEstimate.map { "\($0.length) × \($0.width) × \($0.height) \($0.unit)" } ?? content,
                    detail: estimates.count > 1 ? "\(estimates.count) objects detected" : "",
                    explanation: explanation,
                    raw: content,
                    dimensionEstimates: estimates
                )
            }

            // Calorie Counter mode: parse multi-item food response
            if mode == .calorieCounter, let items = parsed["items"] as? [[String: Any]] {
                let estimates = items.compactMap { item -> ParsedCalorieEstimate? in
                    guard let name = item["name"] as? String else { return nil }

                    let portion = item["portion"] as? String ?? ""
                    let calories = (item["calories"] as? NSNumber)?.intValue ?? 0
                    let protein = (item["protein"] as? NSNumber)?.doubleValue ?? 0
                    let carbs = (item["carbs"] as? NSNumber)?.doubleValue ?? 0
                    let fat = (item["fat"] as? NSNumber)?.doubleValue ?? 0

                    return ParsedCalorieEstimate(name: name, portion: portion, calories: calories, protein: protein, carbs: carbs, fat: fat)
                }

                let totalCal = estimates.reduce(0) { $0 + $1.calories }
                let explanation = parsed["explanation"] as? String ?? ""

                return VisionAnalysis(
                    title: estimates.first?.name ?? "Calorie Counter",
                    value: "\(totalCal) kcal",
                    detail: estimates.count > 1 ? "\(estimates.count) food items detected" : estimates.first?.portion ?? "",
                    explanation: explanation,
                    raw: content,
                    calorieEstimates: estimates
                )
            }

            // Translate mode: parse translation response
            if mode == .translate, let translatedText = parsed["translatedText"] as? String {
                let sourceLanguage = parsed["sourceLanguage"] as? String ?? "Unknown"
                let notes = parsed["translationNotes"] as? String ?? ""
                let result = ParsedTranslationResult(
                    translatedText: translatedText,
                    sourceLanguage: sourceLanguage,
                    translationNotes: notes
                )

                return VisionAnalysis(
                    title: "Translation",
                    value: translatedText,
                    detail: "From \(sourceLanguage)",
                    explanation: notes,
                    raw: content,
                    translationResult: result
                )
            }

            // Plant Identifier mode: parse multi-plant response
            if mode == .plantIdentifier, let plants = parsed["plants"] as? [[String: Any]] {
                let identifications = plants.compactMap { plant -> ParsedPlantIdentification? in
                    guard let commonName = plant["commonName"] as? String,
                          let scientificName = plant["scientificName"] as? String else { return nil }
                    let description = plant["description"] as? String ?? ""
                    let confidence = plant["confidence"] as? String ?? "medium"
                    return ParsedPlantIdentification(commonName: commonName, scientificName: scientificName, description: description, confidence: confidence)
                }

                let explanation = parsed["explanation"] as? String ?? ""

                return VisionAnalysis(
                    title: identifications.first?.commonName ?? "Plant Identifier",
                    value: identifications.first?.commonName ?? content,
                    detail: identifications.count > 1 ? "\(identifications.count) plants detected" : identifications.first?.scientificName ?? "",
                    explanation: explanation,
                    raw: content,
                    plantIdentifications: identifications
                )
            }

            // Object Counter mode: parse multi-object count response
            if mode == .objectCounter, let objects = parsed["objects"] as? [[String: Any]] {
                let counts = objects.compactMap { obj -> ParsedObjectCount? in
                    guard let name = obj["name"] as? String else { return nil }
                    let count = (obj["count"] as? NSNumber)?.intValue ?? 1
                    let category = obj["category"] as? String ?? "Other"
                    return ParsedObjectCount(name: name, count: count, category: category)
                }

                let totalCount = counts.reduce(0) { $0 + $1.count }
                let explanation = parsed["explanation"] as? String ?? ""

                return VisionAnalysis(
                    title: counts.first?.name ?? "Object Counter",
                    value: "\(totalCount) object\(totalCount == 1 ? "" : "s")",
                    detail: counts.count > 1 ? "\(counts.count) types detected" : "",
                    explanation: explanation,
                    raw: content,
                    objectCounts: counts
                )
            }

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
