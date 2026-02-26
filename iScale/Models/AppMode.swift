import SwiftUI

/// All available analysis modes in the app.
enum AppMode: String, CaseIterable, Identifiable {
    case digitalScale = "Digital Scale"
    case tapeMeasure = "Tape Measure"
    case calorieCounter = "Calorie Counter"
    case plantIdentifier = "Plant Identifier"
    case translate = "Translate"
    case objectCounter = "Object Counter"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .digitalScale: return "scalemass.fill"
        case .tapeMeasure: return "ruler.fill"
        case .calorieCounter: return "flame.fill"
        case .plantIdentifier: return "leaf.fill"
        case .translate: return "character.book.closed.fill"
        case .objectCounter: return "number.square.fill"
        }
    }

    var color: Color {
        switch self {
        case .digitalScale: return .cyan
        case .tapeMeasure: return .orange
        case .calorieCounter: return .red
        case .plantIdentifier: return .green
        case .translate: return .blue
        case .objectCounter: return .purple
        }
    }

    /// System prompt hint for the Vision API (stub).
    var analysisPrompt: String {
        switch self {
        case .digitalScale: return "Estimate the weight of the object in the image."
        case .tapeMeasure: return "Estimate the dimensions of the object in the image."
        case .calorieCounter: return "Estimate the calories in the food shown."
        case .plantIdentifier: return "Identify the plant species in the image."
        case .translate: return "Translate any text visible in the image."
        case .objectCounter: return "Count the objects in the image."
        }
    }
}
