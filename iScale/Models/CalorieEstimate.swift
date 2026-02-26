import UIKit

/// A single food item identified in the image with its estimated calories and macros.
struct CalorieEstimate: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let portionSize: String
    let thumbnail: UIImage?

    /// Formatted macro breakdown string.
    var formattedMacros: String {
        "P: \(formatted(protein))g · C: \(formatted(carbs))g · F: \(formatted(fat))g"
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}
