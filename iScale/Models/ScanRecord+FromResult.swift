import Foundation
import UIKit

extension ScanRecord {
    /// Create a ScanRecord from an AnalysisResult.
    static func from(_ result: AnalysisResult) -> ScanRecord {
        let encoder = JSONEncoder()
        var jsonData: Data?

        switch result.mode {
        case .digitalScale:
            let items = result.weightEstimates.map {
                CodableWeightEstimate(name: $0.name, weight: $0.weight)
            }
            jsonData = try? encoder.encode(items)
        case .tapeMeasure:
            let items = result.dimensionEstimates.map {
                CodableDimensionEstimate(name: $0.name, length: $0.length, width: $0.width, height: $0.height, unit: $0.unit)
            }
            jsonData = try? encoder.encode(items)
        case .calorieCounter:
            let items = result.calorieEstimates.map {
                CodableCalorieEstimate(name: $0.name, calories: $0.calories, protein: $0.protein, carbs: $0.carbs, fat: $0.fat, portionSize: $0.portionSize)
            }
            jsonData = try? encoder.encode(items)
        case .translate:
            if let t = result.translationResult {
                jsonData = try? encoder.encode(
                    CodableTranslationResult(translatedText: t.translatedText, sourceLanguage: t.sourceLanguage, translationNotes: t.translationNotes)
                )
            }
        case .plantIdentifier:
            let items = result.plantIdentifications.map {
                CodablePlantIdentification(commonName: $0.commonName, scientificName: $0.scientificName, description: $0.description, confidence: $0.confidence)
            }
            jsonData = try? encoder.encode(items)
        case .objectCounter:
            let items = result.objectCounts.map {
                CodableObjectCount(name: $0.name, count: $0.count, category: $0.category)
            }
            jsonData = try? encoder.encode(items)
        }

        return ScanRecord(
            mode: result.mode,
            title: result.title,
            value: result.value,
            detail: result.detail,
            aiExplanation: result.aiExplanation,
            thumbnail: result.thumbnail,
            resultsJSON: jsonData
        )
    }
}
