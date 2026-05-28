import SwiftUI
import AVFoundation

public struct QRScannerView: View {
    private let onScan: (String) -> Void
    @State private var scanLineOffset: CGFloat = -110
    @State private var cameraDenied = false

    public init(onScan: @escaping (String) -> Void) {
        self.onScan = onScan
    }

    public var body: some View {
        ZStack {
            QRScannerRepresentable(
                onScan: onScan,
                cameraDenied: $cameraDenied
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.45))
                        .frame(width: 280, height: 280)

                    // Cyan scanning line
                    Rectangle()
                        .fill(Color.cyan)
                        .frame(width: 240, height: 2)
                        .offset(y: scanLineOffset)
                        .shadow(color: Color.cyan.opacity(0.9), radius: 8)

                    // White L-brackets
                    ScannerCornerBrackets()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 280, height: 280)
                }
                .frame(width: 280, height: 280)
                .onAppear {
                    scanLineOffset = -110
                    withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
                        scanLineOffset = 110
                    }
                }

                Spacer()
            }
            .padding(.vertical, 40)

            if cameraDenied {
                VStack {
                    Spacer()
                    Text("Permiso de cámara requerido — ve a Ajustes")
                        .font(.headline)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 28)
                }
            }
        }
    }
}

private struct QRScannerRepresentable: UIViewRepresentable {
    let onScan: (String) -> Void
    @Binding var cameraDenied: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan, cameraDenied: $cameraDenied)
    }

    func makeUIView(context: Context) -> ScannerPreviewView {
        let view = ScannerPreviewView()
        view.backgroundColor = .black
        context.coordinator.attachPreview(to: view)
        context.coordinator.startSessionIfNeeded()
        return view
    }

    func updateUIView(_ uiView: ScannerPreviewView, context: Context) {
        context.coordinator.startSessionIfNeeded()
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        private let onScan: (String) -> Void
        private var cameraDenied: Binding<Bool>
        private let session = AVCaptureSession()
        private let sessionQueue = DispatchQueue(label: "com.unipark.qrscanner.session")
        private var previewLayer: AVCaptureVideoPreviewLayer?
        private var hasConfigured = false
        private var didScan = false

        init(onScan: @escaping (String) -> Void, cameraDenied: Binding<Bool>) {
            self.onScan = onScan
            self.cameraDenied = cameraDenied
        }

        func attachPreview(to view: ScannerPreviewView) {
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            view.previewLayer = layer
            previewLayer = layer
        }

        func startSessionIfNeeded() {
            sessionQueue.async { [weak self] in
                guard let self else { return }
                guard !self.didScan else { return }

                switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .authorized:
                    self.configureAndStartSessionIfNeeded()
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        self.sessionQueue.async {
                            if granted {
                                self.configureAndStartSessionIfNeeded()
                            } else {
                                DispatchQueue.main.async {
                                    self.cameraDenied.wrappedValue = true
                                }
                            }
                        }
                    }
                case .denied, .restricted:
                    DispatchQueue.main.async {
                        self.cameraDenied.wrappedValue = true
                    }
                @unknown default:
                    DispatchQueue.main.async {
                        self.cameraDenied.wrappedValue = true
                    }
                }
            }
        }

        private func configureAndStartSessionIfNeeded() {
            guard !hasConfigured else {
                if !session.isRunning {
                    session.startRunning()
                }
                return
            }

            hasConfigured = true
            DispatchQueue.main.async {
                self.cameraDenied.wrappedValue = false
            }

            session.beginConfiguration()
            session.sessionPreset = .high

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                session.commitConfiguration()
                DispatchQueue.main.async {
                    self.cameraDenied.wrappedValue = true
                }
                return
            }

            session.addInput(input)

            let metadataOutput = AVCaptureMetadataOutput()
            guard session.canAddOutput(metadataOutput) else {
                session.commitConfiguration()
                return
            }

            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: sessionQueue)
            metadataOutput.metadataObjectTypes = [.qr]

            session.commitConfiguration()
            session.startRunning()
        }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard !didScan else { return }
            guard
                let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                object.type == .qr,
                let code = object.stringValue,
                !code.isEmpty
            else { return }

            didScan = true
            sessionQueue.async { [weak self] in
                self?.session.stopRunning()
            }

            DispatchQueue.main.async { [onScan] in
                onScan(code)
            }
        }
    }
}

private final class ScannerPreviewView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            oldValue?.removeFromSuperlayer()
            if let previewLayer {
                layer.insertSublayer(previewLayer, at: 0)
                previewLayer.frame = bounds
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

private struct ScannerCornerBrackets: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length: CGFloat = 24

        // top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))

        // top-right
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        // bottom-left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.maxY))

        // bottom-right
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - length))

        return path
    }
}
