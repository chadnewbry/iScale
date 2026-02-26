import SwiftUI

struct ScaleView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @State private var weight: Double = 0.0


    private var unit: String {
        settings.unitSystem == .metric ? "g" : "oz"
    }

    private var displayWeight: Double {
        settings.unitSystem == .imperial ? weight * 0.035274 : weight
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Weight display
            VStack(spacing: 8) {
                Text(String(format: "%.1f", displayWeight))
                    .font(.system(size: 72, weight: .thin, design: .rounded))
                    .monospacedDigit()

                Text(unit)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)

            Spacer()

            // Controls
            HStack(spacing: 20) {
                Button {
                    weight = 0.0
                } label: {
                    Label("Tare", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }

                Button {
                    settings.unitSystem = settings.unitSystem == .metric ? .imperial : .metric
                } label: {
                    Label("Unit", systemImage: "arrow.triangle.2.circlepath")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .navigationTitle("iScale")
    }
}

#Preview {
    NavigationStack {
        ScaleView()
    }
}
