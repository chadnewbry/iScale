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
