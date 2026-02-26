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
}
