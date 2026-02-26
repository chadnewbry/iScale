import UIKit

/// A single identified plant from the Vision API.
struct PlantIdentification: Identifiable {
    let id = UUID()
    let commonName: String
    let scientificName: String
    let description: String
    let confidence: String
    let thumbnail: UIImage?
}
