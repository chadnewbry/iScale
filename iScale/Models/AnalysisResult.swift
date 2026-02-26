import UIKit

/// Result from analyzing a captured image.
struct AnalysisResult: Identifiable {
    let id = UUID()
    let mode: AppMode
    let thumbnail: UIImage?
    let title: String
    let value: String
    let detail: String
    let aiExplanation: String

    /// For Digital Scale mode: individual object weight estimates.
    var weightEstimates: [WeightEstimate] = []

    /// For Tape Measure mode: individual object dimension estimates.
    var dimensionEstimates: [DimensionEstimate] = []

    /// For Calorie Counter mode: individual food item calorie estimates.
    var calorieEstimates: [CalorieEstimate] = []

    /// For Plant Identifier mode: individual plant identifications.
    var plantIdentifications: [PlantIdentification] = []

    /// Total calories across all food items.
    var totalCalories: Int { calorieEstimates.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double { calorieEstimates.reduce(0) { $0 + $1.protein } }
    var totalCarbs: Double { calorieEstimates.reduce(0) { $0 + $1.carbs } }
    var totalFat: Double { calorieEstimates.reduce(0) { $0 + $1.fat } }
}
