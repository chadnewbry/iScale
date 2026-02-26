import Foundation

enum UnitSystem: String, CaseIterable {
    case metric = "Metric"
    case imperial = "Imperial"
}

final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let unitSystemKey = "unitSystem"

    @Published var unitSystem: UnitSystem {
        didSet {
            UserDefaults.standard.set(unitSystem.rawValue, forKey: unitSystemKey)
        }
    }

    private init() {
        let stored = UserDefaults.standard.string(forKey: unitSystemKey) ?? UnitSystem.metric.rawValue
        self.unitSystem = UnitSystem(rawValue: stored) ?? .metric
    }
}
