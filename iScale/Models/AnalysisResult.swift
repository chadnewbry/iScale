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
}
