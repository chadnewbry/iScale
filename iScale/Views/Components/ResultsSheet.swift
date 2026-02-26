import SwiftUI

/// Bottom sheet displaying analysis results with thumbnail, data, and AI explanation.
struct ResultsSheet: View {
    let result: AnalysisResult
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with dismiss
            HStack {
                Text("Results")
                    .font(.headline)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if result.mode == .digitalScale && !result.weightEstimates.isEmpty {
                        digitalScaleResults
                    } else if result.mode == .tapeMeasure && !result.dimensionEstimates.isEmpty {
                        tapeMeasureResults
                    } else if result.mode == .calorieCounter && !result.calorieEstimates.isEmpty {
                        calorieCounterResults
                    } else {
                        genericResult
                    }

                    // AI explanation
                    if !result.aiExplanation.isEmpty {
                        analyzeSection
                    }
                }
            }

            Spacer()
        }
        .padding()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Digital Scale Multi-Object Results

    private var digitalScaleResults: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(result.weightEstimates) { estimate in
                HStack(spacing: 16) {
                    if let thumbnail = estimate.thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "scalemass.fill")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(estimate.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(estimate.weight)
                            .font(.title2.bold())
                    }

                    Spacer()
                }
                .padding(.vertical, 4)

                if estimate.id != result.weightEstimates.last?.id {
                    Divider()
                }
            }
        }
    }

    // MARK: - Tape Measure Multi-Object Results

    private var tapeMeasureResults: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(result.dimensionEstimates) { estimate in
                HStack(spacing: 16) {
                    if let thumbnail = estimate.thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "ruler.fill")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(estimate.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(estimate.formattedDimensions)
                            .font(.title3.bold())
                        HStack(spacing: 12) {
                            dimensionLabel("L", value: estimate.length, unit: estimate.unit)
                            dimensionLabel("W", value: estimate.width, unit: estimate.unit)
                            dimensionLabel("H", value: estimate.height, unit: estimate.unit)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.vertical, 4)

                if estimate.id != result.dimensionEstimates.last?.id {
                    Divider()
                }
            }
        }
    }

    private func dimensionLabel(_ label: String, value: String, unit: String) -> some View {
        HStack(spacing: 2) {
            Text(label)
                .fontWeight(.semibold)
            Text("\(value) \(unit)")
        }
    }

    // MARK: - Calorie Counter Results

    private var calorieCounterResults: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(result.calorieEstimates) { estimate in
                HStack(spacing: 16) {
                    if let thumbnail = estimate.thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "flame.fill")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(estimate.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\(estimate.calories) kcal")
                            .font(.title2.bold())
                        Text(estimate.formattedMacros)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if !estimate.portionSize.isEmpty {
                            Text(estimate.portionSize)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, 4)

                if estimate.id != result.calorieEstimates.last?.id {
                    Divider()
                }
            }

            // Totals row
            if result.calorieEstimates.count > 1 {
                Divider()
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Total")
                        .font(.subheadline.bold())
                    Text("\(result.totalCalories) kcal")
                        .font(.title.bold())
                        .foregroundStyle(.red)
                    HStack(spacing: 12) {
                        macroLabel("Protein", value: result.totalProtein)
                        macroLabel("Carbs", value: result.totalCarbs)
                        macroLabel("Fat", value: result.totalFat)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func macroLabel(_ label: String, value: Double) -> some View {
        HStack(spacing: 2) {
            Text(label)
                .fontWeight(.semibold)
            Text(String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0fg" : "%.1fg", value))
        }
    }

    // MARK: - Generic Single Result

    private var genericResult: some View {
        HStack(spacing: 16) {
            if let thumbnail = result.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: 72, height: 72)
                    .overlay(
                        Image(systemName: result.mode.icon)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(result.value)
                    .font(.title.bold())
                if !result.detail.isEmpty {
                    Text(result.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }

    // MARK: - Analyze Section

    private var analyzeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Analyze", systemImage: "sparkles")
                .font(.subheadline.bold())
                .foregroundStyle(result.mode.color)

            Text(result.aiExplanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
}
