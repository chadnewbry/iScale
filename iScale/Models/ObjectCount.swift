import UIKit

/// A single object type identified and counted in the image.
struct ObjectCount: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let category: String
    let thumbnail: UIImage?
}
