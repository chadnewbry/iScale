import AVFoundation
import UIKit

@MainActor
final class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var isConfigured = false
    private var device: AVCaptureDevice?

    @Published var isFlashOn = false

    private var photoContinuation: CheckedContinuation<UIImage?, Never>?

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

    func toggleFlash() {
        guard let device, device.hasTorch else { return }
        isFlashOn.toggle()
        try? device.lockForConfiguration()
        device.torchMode = isFlashOn ? .on : .off
        device.unlockForConfiguration()
    }

    /// Capture a photo asynchronously and return the resulting UIImage.
    func capturePhoto() async -> UIImage? {
        guard isConfigured else { return nil }

        return await withCheckedContinuation { continuation in
            self.photoContinuation = continuation
            let settings = AVCapturePhotoSettings()
            if let device, device.hasTorch, isFlashOn {
                settings.flashMode = .on
            } else {
                settings.flashMode = .off
            }
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    private func configure() {
        guard let cam = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: cam) else {
            return
        }
        self.device = cam

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

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraManager: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let image: UIImage?
        if let data = photo.fileDataRepresentation() {
            image = UIImage(data: data)
        } else {
            image = nil
        }

        Task { @MainActor in
            self.photoContinuation?.resume(returning: image)
            self.photoContinuation = nil
        }
    }
}
