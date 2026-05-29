import SwiftUI
import AVFoundation

public struct ScannerTab: View {
    var viewModel: GuardViewModel
    @State private var scannedPayload: String = ""
    @State private var cameraActive: Bool = true

    public init(viewModel: GuardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.upBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                UniParkHeader {
                    NotificationCenter.default.post(name: Notification.Name("signOut"), object: nil)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // MARK: Lot Selector
                        if viewModel.lots.isEmpty {
                            HStack(spacing: 8) {
                                ProgressView().tint(Color.upPrimary).scaleEffect(0.8)
                                Text("Cargando lotes...")
                                    .font(.caption)
                                    .foregroundStyle(Color.upTextSecondary)
                            }
                            .padding(.horizontal, 16)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.lots, id: \.id) { lot in
                                        Button {
                                            viewModel.selectedLotId = lot.id
                                        } label: {
                                            Text(lot.name)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(
                                                    lot.id == viewModel.selectedLotId
                                                        ? Color.upBackground : Color.upTextPrimary
                                                )
                                                .padding(.horizontal, 12).padding(.vertical, 8)
                                                .background(
                                                    lot.id == viewModel.selectedLotId
                                                        ? Color.upPrimary : Color.upSurface
                                                )
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        // MARK: Viewfinder con cámara real
                        VStack(spacing: 20) {
                            ZStack {
                                // Cámara real
                                if cameraActive && viewModel.scanStatus != .verifying {
                                    QRCameraView(onQRDetected: { payload in
                                        guard !viewModel.isScanCooldown else { return }
                                        scannedPayload = payload
                                        cameraActive = false
                                    })
                                    .frame(width: 280, height: 280)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    Color.black
                                        .frame(width: 280, height: 280)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                                // Loading overlay durante verificación
                                if viewModel.scanStatus == .verifying {
                                    VStack(spacing: 12) {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .tint(Color.upPrimary)
                                            .scaleEffect(1.4)
                                        Text("Verificando...")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Color.upPrimary)
                                    }
                                }

                                // Corner brackets — color según estado
                                ScanCornerBrackets()
                                    .stroke(bracketColor, lineWidth: 2)
                                    .frame(width: 280, height: 280)
                                    .animation(.easeInOut(duration: 0.3), value: bracketColor)

                                // Instrucción cuando cámara activa
                                if cameraActive && viewModel.scanStatus == .idle {
                                    VStack {
                                        Spacer()
                                        Text("Apunta al QR del conductor")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 12).padding(.vertical, 6)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Capsule())
                                            .padding(.bottom, 10)
                                    }
                                    .frame(width: 280, height: 280)
                                }
                            }

                            // Payload detectado — elige dirección
                            if !scannedPayload.isEmpty && viewModel.scanStatus == .idle {
                                VStack(spacing: 10) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "qrcode.viewfinder")
                                            .foregroundStyle(Color.upSecondary)
                                        Text("QR detectado — elige dirección")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Color.upTextPrimary)
                                    }

                                    if !viewModel.lotsLoaded {
                                        HStack(spacing: 8) {
                                            ProgressView().tint(Color.upPrimary).scaleEffect(0.8)
                                            Text("Esperando lotes del servidor...")
                                                .font(.caption)
                                                .foregroundStyle(Color.upTextSecondary)
                                        }
                                    } else {
                                        HStack(spacing: 12) {
                                            Button {
                                                viewModel.processScan(direction: .entry, payload: scannedPayload)
                                                scannedPayload = ""
                                            } label: {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "arrow.right.circle.fill")
                                                    Text("ENTRADA").font(.caption.weight(.bold))
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .foregroundStyle(Color.upBackground)
                                                .background(Color.upSecondary)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            }

                                            Button {
                                                viewModel.processScan(direction: .exit, payload: scannedPayload)
                                                scannedPayload = ""
                                            } label: {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "arrow.left.circle")
                                                    Text("SALIDA").font(.caption.weight(.bold))
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .foregroundStyle(Color.upError)
                                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.upError, lineWidth: 1.5))
                                            }
                                        }
                                    }

                                    Button {
                                        scannedPayload = ""
                                        cameraActive = true
                                    } label: {
                                        Text("Cancelar — volver a escanear")
                                            .font(.caption)
                                            .foregroundStyle(Color.upTextSecondary)
                                    }
                                }
                                .padding(14)
                                .background(Color.upSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }

                            // Botones manuales (modo debug / sin cámara)
                            if scannedPayload.isEmpty && viewModel.scanStatus == .idle {
                                VStack(spacing: 8) {
                                    Text("O usa el payload de prueba:")
                                        .font(.caption2)
                                        .foregroundStyle(Color.upTextSecondary)

                                    HStack(spacing: 12) {
                                        Button {
                                            viewModel.processScan(direction: .entry)
                                        } label: {
                                            HStack(spacing: 8) {
                                                Image(systemName: "arrow.right.circle.fill")
                                                Text("ENTRADA").font(.caption.weight(.bold))
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .foregroundStyle(Color.upBackground)
                                            .background(
                                                viewModel.isScanCooldown || !viewModel.lotsLoaded
                                                    ? Color.upSurfaceHighest : Color.upSecondary
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        .disabled(viewModel.isScanCooldown || !viewModel.lotsLoaded)

                                        Button {
                                            viewModel.processScan(direction: .exit)
                                        } label: {
                                            HStack(spacing: 8) {
                                                Image(systemName: "arrow.left.circle")
                                                Text("SALIDA").font(.caption.weight(.bold))
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .foregroundStyle(
                                                viewModel.isScanCooldown || !viewModel.lotsLoaded
                                                    ? Color.upTextSecondary : Color.upError
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(
                                                        viewModel.isScanCooldown || !viewModel.lotsLoaded
                                                            ? Color.upSurfaceHighest : Color.upError,
                                                        lineWidth: 1.5
                                                    )
                                            )
                                        }
                                        .disabled(viewModel.isScanCooldown || !viewModel.lotsLoaded)
                                    }
                                }
                            }

                            // MARK: Result Card
                            resultCard
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .onChange(of: viewModel.scanStatus) { _, newStatus in
            // Reactivar cámara cuando el estado vuelve a idle
            if case .idle = newStatus {
                cameraActive = true
            }
        }
    }

    // MARK: - Result Card

    @ViewBuilder
    private var resultCard: some View {
        switch viewModel.scanStatus {
        case .idle:
            EmptyView()

        case .verifying:
            HStack(spacing: 12) {
                ProgressView().tint(Color.upPrimary)
                Text("Verificando pase con el servidor...")
                    .font(.subheadline)
                    .foregroundStyle(Color.upTextSecondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.upSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .transition(.move(edge: .bottom).combined(with: .opacity))

        case .accepted(let outcome):
            if case .valid(let driverName, _) = outcome {
                ScanResultCard(
                    icon: "checkmark.seal.fill",
                    iconColor: .upSecondary,
                    badge: viewModel.lastScanDirection ?? "ENTRADA",
                    badgeColor: .upSecondary,
                    title: driverName,
                    detail: outcome.displayDetail,
                    lot: viewModel.selectedLot?.name ?? "",
                    time: viewModel.lastScanTime ?? ""
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

        case .rejected(let outcome):
            ScanResultCard(
                icon: rejectionIcon(for: outcome),
                iconColor: .upError,
                badge: "RECHAZADO",
                badgeColor: .upError,
                title: outcome.displayTitle,
                detail: viewModel.backendErrorMessage ?? outcome.displayDetail,
                lot: viewModel.selectedLot?.name ?? "",
                time: viewModel.lastScanTime ?? ""
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Helpers

    private var bracketColor: Color {
        switch viewModel.scanStatus {
        case .idle:       return scannedPayload.isEmpty ? Color.upPrimary : Color.upSecondary
        case .verifying:  return Color.upPrimary.opacity(0.4)
        case .accepted:   return Color.upSecondary
        case .rejected:   return Color.upError
        }
    }

    private func rejectionIcon(for outcome: VerificationOutcome) -> String {
        switch outcome {
        case .expired:          return "clock.badge.xmark"
        case .alreadyUsed:      return "doc.badge.clock"
        case .wrongLot:         return "mappin.slash"
        case .revoked:          return "nosign"
        case .invalidSignature: return "exclamationmark.shield.fill"
        default:                return "xmark.circle.fill"
        }
    }
}

// MARK: - QR Camera View (AVFoundation)
// sessionQueue exclusiva: startRunning/stopRunning NUNCA en main thread.

struct QRCameraView: UIViewRepresentable {
    let onQRDetected: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onQRDetected: onQRDetected)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let preview = AVCaptureVideoPreviewLayer()
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
        context.coordinator.previewLayer = preview

        context.coordinator.sessionQueue.async {
            context.coordinator.setupSession(preview: preview)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.previewLayer?.frame = uiView.bounds
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.sessionQueue.async {
            coordinator.session?.stopRunning()
            coordinator.session = nil
        }
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onQRDetected: (String) -> Void
        var session: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        let sessionQueue = DispatchQueue(label: "com.unipark.camera", qos: .userInitiated)
        private var didDetect = false

        init(onQRDetected: @escaping (String) -> Void) {
            self.onQRDetected = onQRDetected
        }

        func setupSession(preview: AVCaptureVideoPreviewLayer) {
            let s = AVCaptureSession()
            self.session = s

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  s.canAddInput(input) else { return }

            s.beginConfiguration()
            s.addInput(input)
            let output = AVCaptureMetadataOutput()
            if s.canAddOutput(output) {
                s.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: sessionQueue)
                output.metadataObjectTypes = [.qr]
            }
            s.commitConfiguration()

            DispatchQueue.main.async { preview.session = s }
            s.startRunning()
        }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard !didDetect,
                  let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  obj.type == .qr,
                  let value = obj.stringValue else { return }
            didDetect = true
            session?.stopRunning()
            DispatchQueue.main.async { [weak self] in
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self?.onQRDetected(value)
            }
        }
    }
}

// MARK: - Animated Scan Line

private struct AnimatedScanLine: View {
    @State private var offset: CGFloat = -120

    var body: some View {
        LinearGradient(
            colors: [.clear, Color.upPrimary, .clear],
            startPoint: .top, endPoint: .bottom
        )
        .frame(height: 2)
        .offset(y: offset)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                offset = 120
            }
        }
    }
}

// MARK: - Corner Brackets

private struct ScanCornerBrackets: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let len: CGFloat = 20
        p.move(to: CGPoint(x: rect.minX, y: rect.minY + len))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX + len, y: rect.minY))
        p.move(to: CGPoint(x: rect.maxX - len, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + len))
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY - len))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + len, y: rect.maxY))
        p.move(to: CGPoint(x: rect.maxX - len, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - len))
        return p
    }
}

// MARK: - Result Card

private struct ScanResultCard: View {
    let icon: String
    let iconColor: Color
    let badge: String
    let badgeColor: Color
    let title: String
    let detail: String
    let lot: String
    let time: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(iconColor)

                VStack(alignment: .leading, spacing: 3) {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(badgeColor)
                        .padding(.horizontal, 7).padding(.vertical, 2)
                        .background(badgeColor.opacity(0.15))
                        .clipShape(Capsule())

                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.upTextPrimary)
                }

                Spacer()

                Text(time)
                    .font(.caption)
                    .foregroundStyle(Color.upTextSecondary)
            }

            Text(detail)
                .font(.caption)
                .foregroundStyle(Color.upTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider().background(Color.upOutlineVariant)

            HStack(spacing: 16) {
                Label(lot, systemImage: "parkingsign.circle")
                    .font(.caption)
                    .foregroundStyle(Color.upTextSecondary)
            }
        }
        .padding(14)
        .background(Color.upSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(iconColor.opacity(0.5), lineWidth: 1.2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: iconColor.opacity(0.15), radius: 8)
    }
}
