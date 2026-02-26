import SwiftUI

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var currentMode: AppMode = .digitalScale
    @State private var showModePicker = false
    @State private var analysisResult: AnalysisResult?
    @State private var showResults = false
    @State private var isAnalyzing = false

    var body: some View {
        ZStack {
            // Full-screen camera preview
            CameraPreviewView(cameraManager: cameraManager)
                .ignoresSafeArea()

            // Gradient overlays for readability
            VStack {
                LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 120)
                Spacer()
                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 200)
            }
            .ignoresSafeArea()

            // Main UI overlay
            VStack {
                // Top bar
                topBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                Spacer()

                // Capture button
                captureButton
                    .padding(.bottom, 16)

                // Ad banner
                BannerAdView()
                    .frame(height: 50)
            }
        }
        .sheet(isPresented: $showModePicker) {
            ModePickerSheet(selectedMode: $currentMode)
        }
        .sheet(isPresented: $showResults) {
            if let result = analysisResult {
                ResultsSheet(result: result) {
                    showResults = false
                    analysisResult = nil
                }
            }
        }
        .onAppear { cameraManager.start() }
        .onDisappear { cameraManager.stop() }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            ModePillView(mode: currentMode) {
                showModePicker = true
            }

            Spacer()

            // Flash toggle
            Button {
                cameraManager.toggleFlash()
            } label: {
                Image(systemName: cameraManager.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
            }

            // Settings (navigates to settings tab — stub)
            Button {
                // Placeholder: settings accessed from tab bar
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
    }

    // MARK: - Capture Button

    private var captureButton: some View {
        Button {
            captureAndAnalyze()
        } label: {
            ZStack {
                Circle()
                    .stroke(.white, lineWidth: 4)
                    .frame(width: 80, height: 80)

                Circle()
                    .fill(.white)
                    .frame(width: 66, height: 66)

                if isAnalyzing {
                    ProgressView()
                        .tint(.black)
                }
            }
        }
        .disabled(isAnalyzing)
    }

    // MARK: - Capture & Analyze

    private func captureAndAnalyze() {
        isAnalyzing = true

        Task {
            let image = cameraManager.capturePhoto()

            do {
                let analysis = try await VisionService.shared.analyze(image: image, mode: currentMode)
                await MainActor.run {
                    var result = AnalysisResult(
                        mode: currentMode,
                        thumbnail: image,
                        title: analysis.title,
                        value: analysis.value,
                        detail: analysis.detail,
                        aiExplanation: analysis.explanation
                    )
                    // Attach weight estimates for Digital Scale mode
                    if currentMode == .digitalScale {
                        result.weightEstimates = analysis.weightEstimates.map {
                            WeightEstimate(name: $0.name, weight: "\($0.weight) \($0.unit)", thumbnail: image)
                        }
                    }
                    // Attach calorie estimates for Calorie Counter mode
                    if currentMode == .calorieCounter {
                        result.calorieEstimates = analysis.calorieEstimates.map {
                            CalorieEstimate(name: $0.name, calories: $0.calories, protein: $0.protein, carbs: $0.carbs, fat: $0.fat, portionSize: $0.portion, thumbnail: image)
                        }
                    }
                    // Attach plant identifications for Plant Identifier mode
                    if currentMode == .plantIdentifier {
                        result.plantIdentifications = analysis.plantIdentifications.map {
                            PlantIdentification(commonName: $0.commonName, scientificName: $0.scientificName, description: $0.description, confidence: $0.confidence, thumbnail: image)
                        }
                    }
                    // Attach dimension estimates for Tape Measure mode
                    if currentMode == .tapeMeasure {
                        result.dimensionEstimates = analysis.dimensionEstimates.map {
                            DimensionEstimate(name: $0.name, length: $0.length, width: $0.width, height: $0.height, unit: $0.unit, thumbnail: image)
                        }
                    }
                    // Attach translation result for Translate mode
                    if currentMode == .translate, let parsed = analysis.translationResult {
                        result.translationResult = TranslationResult(
                            translatedText: parsed.translatedText,
                            sourceLanguage: parsed.sourceLanguage,
                            translationNotes: parsed.translationNotes,
                            thumbnail: image
                        )
                    }
                    analysisResult = result
                    isAnalyzing = false
                    showResults = true
                }
            } catch {
                await MainActor.run {
                    analysisResult = AnalysisResult(
                        mode: currentMode,
                        thumbnail: image,
                        title: currentMode.rawValue,
                        value: "⚠️ \(error.localizedDescription)",
                        detail: "",
                        aiExplanation: ""
                    )
                    isAnalyzing = false
                    showResults = true
                }
            }
        }
    }
}

#Preview {
    CameraView()
}
