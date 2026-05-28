import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

public struct AccessQRTab: View {
    @State var viewModel: DriverViewModel
    @State private var qrExpanded = false
    @State private var qrImage: UIImage?

    public init(viewModel: DriverViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.upBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                UniParkHeader {
                    NotificationCenter.default.post(name: Notification.Name("signOut"), object: nil)
                }

                Spacer()

                // Clock
                VStack(spacing: 2) {
                    Text(viewModel.currentTime)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.upPrimary)
                    Text(viewModel.currentDate)
                        .font(.subheadline)
                        .foregroundStyle(Color.upTextSecondary)
                }
                .padding(.bottom, 20)

                // QR Card — ocupa la mayoría de la pantalla
                Button(action: { qrExpanded = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.white)
                            .shadow(color: Color.upPrimary.opacity(0.18), radius: 24, x: 0, y: 8)

                        VStack(spacing: 12) {
                            if let qrImage {
                                Image(uiImage: qrImage)
                                    .resizable()
                                    .interpolation(.none)
                                    .frame(width: 280, height: 280)
                                    .padding(8)
                            } else {
                                // Placeholder mientras carga
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .tint(Color.upPrimary)
                                        .scaleEffect(1.4)
                                    Text("Cargando pase...")
                                        .font(.caption)
                                        .foregroundStyle(Color.upTextSecondary)
                                }
                                .frame(width: 280, height: 280)
                            }

                            Divider().padding(.horizontal, 16)

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Pase de Acceso")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.black.opacity(0.6))
                                    Text("Toca para ampliar")
                                        .font(.caption2)
                                        .foregroundStyle(.black.opacity(0.35))
                                }
                                Spacer()
                                // Countdown pill
                                HStack(spacing: 4) {
                                    Image(systemName: "clock.fill")
                                        .font(.caption2)
                                    Text("\(viewModel.passCountdown)s")
                                        .font(.caption.weight(.bold))
                                        .monospacedDigit()
                                }
                                .foregroundStyle(viewModel.passCountdown < 15 ? Color.red : Color.upPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background((viewModel.passCountdown < 15 ? Color.red : Color.upPrimary).opacity(0.1))
                                .clipShape(Capsule())
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)

                // Last scan result
                if let result = viewModel.lastScanResult {
                    HStack(spacing: 12) {
                        Image(systemName: result.direction == .entry ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(result.direction == .entry ? Color.upSecondary : Color.orange)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.direction == .entry ? "Entrada registrada" : "Salida registrada")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.upTextPrimary)
                            Text("\(result.lotName) · \(result.timeString)")
                                .font(.caption)
                                .foregroundStyle(Color.upTextSecondary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.upSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
            }
        }
        // Full-screen expanded QR
        .fullScreenCover(isPresented: $qrExpanded) {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 28) {
                    Text("Pase de Acceso")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    if let qrImage {
                        Image(uiImage: qrImage)
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 340, height: 340)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.upPrimary.opacity(0.4), radius: 32)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.subheadline)
                        Text("Expira en \(viewModel.passCountdown)s")
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                    }
                    .foregroundStyle(viewModel.passCountdown < 15 ? Color.red : Color.upPrimary)

                    Button { qrExpanded = false } label: {
                        Text("Cerrar")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 160)
                            .padding(.vertical, 14)
                            .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                    }
                    Spacer()
                }
                .padding(.top, 48)
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            viewModel.startTimers()
            generateAndDisplayQR()
        }
        .onDisappear { viewModel.stopTimers() }
        .onChange(of: viewModel.passPayload) { _, newPayload in
            if !newPayload.isEmpty, newPayload != "UNIPARK-NO-PASS" {
                qrImage = generateQRImage(from: newPayload)
            }
        }
    }

    private func generateAndDisplayQR() {
        let payload = viewModel.passPayload
        guard !payload.isEmpty, payload != "UNIPARK-NO-PASS" else {
            Task { await viewModel.fetchActivePass() }
            return
        }
        qrImage = generateQRImage(from: payload)
    }

    private func generateQRImage(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(Data(string.utf8), forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let ciImage = filter.outputImage else { return nil }

        let targetSize: CGFloat = 340
        let extent = ciImage.extent.integral
        let scale = min(targetSize / extent.width, targetSize / extent.height)
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
}
