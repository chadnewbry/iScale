import AVFoundation
import UIKit

@MainActor
final class CameraManager: ObservableObject {
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var isConfigured = false
    private var device: AVCaptureDevice?

    @Published var isFlashOn = false

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

    func capturePhoto() -> UIImage? {
        // TODO: Implement actual photo capture via AVCapturePhotoCaptureDelegate
        // For now, return nil (stub)
        return nil
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
