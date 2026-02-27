import SwiftUI

/// Full-screen analysis view that shows the captured photo with a loading state,
/// then transitions to show results once the API responds.
struct AnalysisView: View {
    let image: UIImage
    let mode: AppMode
    let onDismiss: () -> Void

    private enum ViewState {
        case loading
        case results(AnalysisResult)
        case error(String)
    }

    @State private var viewState: ViewState = .loading

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch viewState {
            case .loading:
                loadingContent
            case .results(let result):
                resultsContent(result)
            case .error(let message):
                errorContent(message)
            }

            // Top bar overlay
            VStack {
                topBar
                Spacer()
            }
        }
        .task {
            await runAnalysis()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.body.bold())
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
            }

            Spacer()

            // Mode pill (non-interactive)
            HStack(spacing: 6) {
                Image(systemName: mode.icon)
                    .font(.caption.bold())
                Text(mode.rawValue)
                    .font(.caption.bold())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(mode.color, in: Capsule())
            .foregroundStyle(.white)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Loading State

    private var loadingContent: some View {
        ZStack {
            // Full-bleed captured photo
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Blur/dim overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            // Spinner + label
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                    .tint(mode.color)

                Text("Analyzing...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Results State

    private func resultsContent(_ result: AnalysisResult) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Captured photo pinned at top
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    .clipped()

                // Results content
                ResultsContentView(result: result)
                    .padding()
            }
        }
        .background(Color(.systemBackground))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Error State

    private func errorContent(_ message: String) -> some View {
        ZStack {
            // Full-bleed captured photo
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Dim overlay
            Rectangle()
                .fill(.black.opacity(0.6))
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.yellow)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button {
                    viewState = .loading
                    Task { await runAnalysis() }
                } label: {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(mode.color, in: Capsule())
                }
            }
        }
    }

    // MARK: - Analysis

    private func runAnalysis() async {
        do {
            let analysis = try await VisionService.shared.analyze(image: image, mode: mode)

            var result = AnalysisResult(
                mode: mode,
                thumbnail: image,
                title: analysis.title,
                value: analysis.value,
                detail: analysis.detail,
                aiExplanation: analysis.explanation
            )

            if mode == .digitalScale {
                result.weightEstimates = analysis.weightEstimates.map {
                    WeightEstimate(name: $0.name, weight: "\($0.weight) \($0.unit)", thumbnail: image)
                }
            }
            if mode == .calorieCounter {
                result.calorieEstimates = analysis.calorieEstimates.map {
                    CalorieEstimate(name: $0.name, calories: $0.calories, protein: $0.protein, carbs: $0.carbs, fat: $0.fat, portionSize: $0.portion, thumbnail: image)
                }
            }
            if mode == .plantIdentifier {
                result.plantIdentifications = analysis.plantIdentifications.map {
                    PlantIdentification(commonName: $0.commonName, scientificName: $0.scientificName, description: $0.description, confidence: $0.confidence, thumbnail: image)
                }
            }
            if mode == .tapeMeasure {
                result.dimensionEstimates = analysis.dimensionEstimates.map {
                    DimensionEstimate(name: $0.name, length: $0.length, width: $0.width, height: $0.height, unit: $0.unit, thumbnail: image)
                }
            }
            if mode == .objectCounter {
                result.objectCounts = analysis.objectCounts.map {
                    ObjectCount(name: $0.name, count: $0.count, category: $0.category, thumbnail: image)
                }
            }
            if mode == .translate, let parsed = analysis.translationResult {
                result.translationResult = TranslationResult(
                    translatedText: parsed.translatedText,
                    sourceLanguage: parsed.sourceLanguage,
                    translationNotes: parsed.translationNotes,
                    thumbnail: image
                )
            }

            withAnimation(.easeInOut(duration: 0.4)) {
                viewState = .results(result)
            }

            AdManager.shared.showInterstitial()

        } catch {
            withAnimation {
                viewState = .error(error.localizedDescription)
            }
        }
    }
}
