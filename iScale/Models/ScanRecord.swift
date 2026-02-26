import SwiftData
import UIKit

/// Persisted scan result using SwiftData.
@Model
final class ScanRecord {
    var id: UUID
    var timestamp: Date
    var modeRawValue: String
    var title: String
    var value: String
    var detail: String
    var aiExplanation: String

    /// Thumbnail stored as JPEG data.
    @Attribute(.externalStorage) var thumbnailData: Data?

    /// Sub-results stored as JSON for flexibility across all modes.
    var resultsJSON: Data?

    init(
        mode: AppMode,
        title: String,
        value: String,
        detail: String,
        aiExplanation: String,
        thumbnail: UIImage?,
        resultsJSON: Data? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.modeRawValue = mode.rawValue
        self.title = title
        self.value = value
        self.detail = detail
        self.aiExplanation = aiExplanation
        self.thumbnailData = thumbnail?.jpegData(compressionQuality: 0.7)
        self.resultsJSON = resultsJSON
    }

    var mode: AppMode {
        AppMode(rawValue: modeRawValue) ?? .digitalScale
    }

    var thumbnail: UIImage? {
        thumbnailData.flatMap { UIImage(data: $0) }
    }

    /// Convert back to an AnalysisResult for display in ResultsSheet.
    func toAnalysisResult() -> AnalysisResult {
        let img = thumbnail
        var result = AnalysisResult(
            mode: mode,
            thumbnail: img,
            title: title,
            value: value,
            detail: detail,
            aiExplanation: aiExplanation
        )

        guard let data = resultsJSON else { return result }

        let decoder = JSONDecoder()

        switch mode {
        case .digitalScale:
            if let items = try? decoder.decode([CodableWeightEstimate].self, from: data) {
                result.weightEstimates = items.map {
                    WeightEstimate(name: $0.name, weight: $0.weight, thumbnail: img)
                }
            }
        case .tapeMeasure:
            if let items = try? decoder.decode([CodableDimensionEstimate].self, from: data) {
                result.dimensionEstimates = items.map {
                    DimensionEstimate(name: $0.name, length: $0.length, width: $0.width, height: $0.height, unit: $0.unit, thumbnail: img)
                }
            }
        case .calorieCounter:
            if let items = try? decoder.decode([CodableCalorieEstimate].self, from: data) {
                result.calorieEstimates = items.map {
                    CalorieEstimate(name: $0.name, calories: $0.calories, protein: $0.protein, carbs: $0.carbs, fat: $0.fat, portionSize: $0.portionSize, thumbnail: img)
                }
            }
        case .translate:
            if let item = try? decoder.decode(CodableTranslationResult.self, from: data) {
                result.translationResult = TranslationResult(
                    translatedText: item.translatedText,
                    sourceLanguage: item.sourceLanguage,
                    translationNotes: item.translationNotes,
                    thumbnail: img
                )
            }
        case .plantIdentifier:
            if let items = try? decoder.decode([CodablePlantIdentification].self, from: data) {
                result.plantIdentifications = items.map {
                    PlantIdentification(commonName: $0.commonName, scientificName: $0.scientificName, description: $0.description, confidence: $0.confidence, thumbnail: img)
                }
            }
        case .objectCounter:
            if let items = try? decoder.decode([CodableObjectCount].self, from: data) {
                result.objectCounts = items.map {
                    ObjectCount(name: $0.name, count: $0.count, category: $0.category, thumbnail: img)
                }
            }
        }

        return result
    }

    /// Summary string for the history list row.
    var summary: String {
        switch mode {
        case .digitalScale:
            return value.isEmpty ? title : value
        case .tapeMeasure:
            return value.isEmpty ? title : value
        case .calorieCounter:
            return value.isEmpty ? title : value
        case .translate:
            if let data = resultsJSON,
               let item = try? JSONDecoder().decode(CodableTranslationResult.self, from: data) {
                let text = item.translatedText
                return text.count > 60 ? String(text.prefix(60)) + "…" : text
            }
            return value
        case .plantIdentifier:
            return value.isEmpty ? title : value
        case .objectCounter:
            return value.isEmpty ? title : value
        }
    }
}

// MARK: - Codable helpers for JSON persistence

struct CodableWeightEstimate: Codable {
    let name: String
    let weight: String
}

struct CodableDimensionEstimate: Codable {
    let name: String
    let length: String
    let width: String
    let height: String
    let unit: String
}

struct CodableCalorieEstimate: Codable {
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let portionSize: String
}

struct CodableTranslationResult: Codable {
    let translatedText: String
    let sourceLanguage: String
    let translationNotes: String
}

struct CodablePlantIdentification: Codable {
    let commonName: String
    let scientificName: String
    let description: String
    let confidence: String
}

struct CodableObjectCount: Codable {
    let name: String
    let count: Int
    let category: String
}
