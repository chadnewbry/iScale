import AVFoundation
import UIKit

@MainActor
final class CameraManager: ObservableObject {
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var isConfigured = false

    func start() {
        guard !isConfigured else {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
            return
        }
        configure()
    }

    func stop() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func capturePhoto() -> UIImage? {
        // TODO: Implement actual photo capture via AVCapturePhotoCaptureDelegate
        // For now, return a placeholder
        return nil
    }

    private func configure() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .photo

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
        isConfigured = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
}
