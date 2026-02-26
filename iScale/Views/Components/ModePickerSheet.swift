import SwiftUI

/// Bottom sheet with a 2×3 grid of mode icons.
struct ModePickerSheet: View {
    @Binding var selectedMode: AppMode
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 20) {
            // Handle
            Capsule()
                .fill(.secondary.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 10)

            Text("Choose Mode")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(AppMode.allCases) { mode in
                    ModeCell(mode: mode, isSelected: mode == selectedMode)
                        .onTapGesture {
                            selectedMode = mode
                            dismiss()
                        }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
    }
}

private struct ModeCell: View {
    let mode: AppMode
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isSelected ? mode.color : Color(.systemGray5))
                    .frame(width: 60, height: 60)

                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .primary)
            }

            Text(mode.rawValue)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundStyle(isSelected ? mode.color : .primary)
        }
    }
}
