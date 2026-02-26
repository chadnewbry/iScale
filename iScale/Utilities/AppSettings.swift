import Foundation

/// Centralized UserDefaults keys and default values.
enum AppSettings {
    enum Keys {
        static let unitSystem = "unitSystem"
        static let hapticFeedback = "hapticFeedback"
        static let onboardingComplete = "onboardingComplete"
    }

    enum Defaults {
        static let unitSystem = "imperial"
        static let hapticFeedback = true
        static let onboardingComplete = false
    }
}
