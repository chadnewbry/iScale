import UIKit

/// Result from translating text found in an image.
struct TranslationResult: Identifiable {
    let id = UUID()
    let translatedText: String
    let sourceLanguage: String
    let translationNotes: String
    let thumbnail: UIImage?
}
