import SwiftUI

struct ScaleView: View {
    @State private var weight: Double = 0.0
    @State private var unit: String = "g"

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Weight display
            VStack(spacing: 8) {
                Text(String(format: "%.1f", weight))
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
                    unit = unit == "g" ? "oz" : "g"
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
