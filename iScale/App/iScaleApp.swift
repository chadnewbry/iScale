import SwiftData
import SwiftUI

@main
struct iScaleApp: App {
    init() {
        AdManager.shared.configure()
        _ = StoreManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ScanRecord.self)
    }
}
