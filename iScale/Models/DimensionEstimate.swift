import UIKit

/// A single object identified in the image with its estimated dimensions.
struct DimensionEstimate: Identifiable {
    let id = UUID()
    let name: String
    let length: String
    let width: String
    let height: String
    let unit: String
    let thumbnail: UIImage?

    /// Formatted dimensions string (e.g. "30 × 20 × 15 cm").
    var formattedDimensions: String {
        "\(length) × \(width) × \(height) \(unit)"
    }
}
