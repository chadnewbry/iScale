import SwiftUI

struct UnitPickerOnboardingView: View {
    @AppStorage(AppSettings.Keys.unitSystem) private var unitSystem = AppSettings.Defaults.unitSystem
    @AppStorage(AppSettings.Keys.onboardingComplete) private var onboardingComplete = AppSettings.Defaults.onboardingComplete
    @State private var selectedUnit: String?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Scale icon
                Image(systemName: "scalemass.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.cyan)

                // Title
                Text("Choose your units")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                // Unit cards
                VStack(spacing: 16) {
                    unitCard(
                        title: "Metric",
                        subtitle: "grams, kilograms",
                        value: "metric"
                    )

                    unitCard(
                        title: "Imperial",
                        subtitle: "ounces, pounds",
                        value: "imperial"
                    )
                }
                .padding(.horizontal, 24)

                Spacer()

                // Continue button
                Button {
                    if let selected = selectedUnit {
                        unitSystem = selected
                        onboardingComplete = true
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedUnit != nil ? Color.cyan : Color.cyan.opacity(0.3),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .foregroundStyle(selectedUnit != nil ? .black : .gray)
                }
                .disabled(selectedUnit == nil)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    @ViewBuilder
    private func unitCard(title: String, subtitle: String, value: String) -> some View {
        let isSelected = selectedUnit == value

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedUnit = value
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.cyan)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.cyan.opacity(0.15) : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    UnitPickerOnboardingView()
}
