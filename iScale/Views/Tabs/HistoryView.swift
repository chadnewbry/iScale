import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("No measurements yet")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
}
