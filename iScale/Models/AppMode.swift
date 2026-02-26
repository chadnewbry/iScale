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
    var analysisPrompt: String { systemPrompt }

    /// System prompt sent to the Vision API.
    var systemPrompt: String {
        let jsonFormat = """
        Respond ONLY with a JSON object: {"title":"<short label>","value":"<primary result>","detail":"<secondary info>","explanation":"<brief reasoning>"}
        """
        switch self {
        case .digitalScale:
            return digitalScaleSystemPrompt
        case .tapeMeasure:
            return tapeMeasureSystemPrompt
        case .calorieCounter:
            return calorieCounterSystemPrompt
        case .plantIdentifier:
            return "You are a botanist. Identify the plant species in the image. Include common name, scientific name, and care tips. \(jsonFormat)"
        case .translate:
            return "You are a translator. Find and translate all visible text in the image to English. If already English, note the language. \(jsonFormat)"
        case .objectCounter:
            return "You are an object counting expert. Count the distinct objects in the image. Group by type if there are multiple categories. \(jsonFormat)"
        }
    }

    /// User-facing prompt sent alongside the image.
    var userPrompt: String {
        switch self {
        case .digitalScale: return digitalScaleUserPrompt
        case .tapeMeasure: return tapeMeasureUserPrompt
        case .calorieCounter: return "Identify all food items in this image. For each item, estimate the portion size, calories, and macronutrients (protein, carbs, fat)."
        case .plantIdentifier: return "What plant is this?"
        case .translate: return "Translate the text in this image."
        case .objectCounter: return "How many objects are in this image?"
        }
    }

    // MARK: - Digital Scale Prompts

    private var preferredUnits: String {
        let system = UserDefaults.standard.string(forKey: AppSettings.Keys.unitSystem) ?? AppSettings.Defaults.unitSystem
        return system == "metric" ? "grams and kilograms" : "ounces and pounds"
    }

    private var preferredDimensionUnits: String {
        let system = UserDefaults.standard.string(forKey: AppSettings.Keys.unitSystem) ?? AppSettings.Defaults.unitSystem
        return system == "metric" ? "centimeters (cm)" : "inches (in)"
    }

    private var tapeMeasureSystemPrompt: String {
        """
        You are a measurement and object identification expert. Identify ALL distinct objects in the image and estimate the typical real-world dimensions (length, width, height) of each based on what the object typically is.

        Use \(preferredDimensionUnits) for all measurements. These should be typical/average dimensions for that type of object, not pixel-based measurements.

        Respond ONLY with a JSON object in this exact format:
        {"objects":[{"name":"<object name>","length":"<number>","width":"<number>","height":"<number>","unit":"<cm|in>"}],"explanation":"<detailed reasoning about how you identified the objects and determined their typical dimensions>"}
        """
    }

    private var tapeMeasureUserPrompt: String {
        "Identify all objects in this image and estimate the typical dimensions (length, width, height) of each one. Use \(preferredDimensionUnits)."
    }

    private var calorieCounterSystemPrompt: String {
        """
        You are a nutrition expert. Identify ALL distinct food items in the image. For each item, estimate the portion size and provide calorie count and macronutrient breakdown (protein, carbs, fat in grams).

        Be specific about portion sizes (e.g. "1 medium banana ~120g", "2 slices white bread ~60g").

        Respond ONLY with a JSON object in this exact format:
        {"items":[{"name":"<food item name>","portion":"<estimated portion size>","calories":<number>,"protein":<number>,"carbs":<number>,"fat":<number>}],"explanation":"<detailed reasoning about how you identified the food items and estimated portion sizes, referencing visual cues like plate size, utensil comparison, food density, and typical serving sizes>"}
        """
    }

    private var digitalScaleSystemPrompt: String {
        """
        You are a weight estimation expert. Identify ALL distinct objects in the image and estimate the weight of each one based on its apparent size, known average weights, and visual cues like volume and density.

        Use \(preferredUnits) for all weights. Use the smaller unit (grams or ounces) for items under 1 kg/2.2 lbs.

        Respond ONLY with a JSON object in this exact format:
        {"objects":[{"name":"<object name>","weight":"<number>","unit":"<g|kg|oz|lbs>"}],"explanation":"<detailed reasoning about how you estimated the weights, referencing volume, density, and known averages>"}
        """
    }

    private var digitalScaleUserPrompt: String {
        "Identify all objects in this image and estimate the weight of each one. Use \(preferredUnits)."
    }
}
