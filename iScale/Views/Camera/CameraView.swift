import SwiftUI

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var capturedImage: UIImage?
    @State private var analysisResult: String?
    @State private var isAnalyzing = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Camera preview
                    CameraPreviewView(cameraManager: cameraManager)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()

                    // Result overlay
                    if let result = analysisResult {
                        Text(result)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.black.opacity(0.8))
                    }

                    // Capture button
                    Button {
                        captureAndAnalyze()
                    } label: {
                        Circle()
                            .fill(.white)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Circle()
                                    .stroke(.black.opacity(0.2), lineWidth: 3)
                                    .frame(width: 62, height: 62)
                            )
                    }
                    .padding(.vertical, 24)
                    .disabled(isAnalyzing)
                    .opacity(isAnalyzing ? 0.5 : 1.0)

                    // Ad banner placeholder
                    BannerAdView()
                        .frame(height: 50)
                }
            }
            .navigationTitle("iScale")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            cameraManager.start()
        }
        .onDisappear {
            cameraManager.stop()
        }
    }

    private func captureAndAnalyze() {
        isAnalyzing = true
        analysisResult = nil

        Task {
            if let image = cameraManager.capturePhoto() {
                capturedImage = image
                let result = await VisionService.shared.analyzeImage(image)
                await MainActor.run {
                    analysisResult = result
                    isAnalyzing = false
                }
            } else {
                await MainActor.run {
                    analysisResult = "Failed to capture image"
                    isAnalyzing = false
                }
            }
        }
    }
}

#Preview {
    CameraView()
}
