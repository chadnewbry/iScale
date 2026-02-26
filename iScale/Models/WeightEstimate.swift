import UIKit

/// A single object identified in the image with its estimated weight.
struct WeightEstimate: Identifiable {
    let id = UUID()
    let name: String
    let weight: String
    let thumbnail: UIImage?
}
