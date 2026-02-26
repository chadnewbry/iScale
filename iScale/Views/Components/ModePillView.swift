import SwiftUI

/// Colored pill showing the current mode name. Tap to open mode picker.
struct ModePillView: View {
    let mode: AppMode
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: mode.icon)
                    .font(.caption.bold())
                Text(mode.rawValue)
                    .font(.caption.bold())
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(mode.color, in: Capsule())
            .foregroundStyle(.white)
        }
    }
}
