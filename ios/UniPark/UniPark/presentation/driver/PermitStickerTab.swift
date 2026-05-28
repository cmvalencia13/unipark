import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

public struct PermitStickerTab: View {
    var viewModel: DriverViewModel
    @State private var showScanner = false

    public init(viewModel: DriverViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.upBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                UniParkHeader {
                    NotificationCenter.default.post(name: Notification.Name("signOut"), object: nil)
                }

                if viewModel.stickerPermit == nil {
                    // MARK: State A — Empty
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            Spacer(minLength: 20)

                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 70, weight: .semibold))
                                .foregroundStyle(Color.upPrimary)
                                .neonGlow(color: .upPrimary, radius: 20)

                            Text("Permiso Físico Digital")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color.upTextPrimary)

                            Text("Escanea tu pegatina universitaria una sola vez para tenerla siempre disponible digitalmente.")
                                .font(.body)
                                .foregroundStyle(Color.upTextSecondary)
                                .multilineTextAlignment(.center)

                            Button(action: { showScanner = true }) {
                                Text("Escanear Pegatina")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .foregroundStyle(Color.upSurfaceLowest)
                                    .background(Color.upSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            Text("Solo necesitas escanearlo una vez. Se guardará en tu perfil.")
                                .font(.caption)
                                .foregroundStyle(Color.upTextSecondary)
                                .multilineTextAlignment(.center)

                            Spacer()
                        }
                        .padding(32)
                    }
                } else if let sticker = viewModel.stickerPermit {
                    // MARK: State B — Display Permit
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            Text("PERMISO UNIVERSITARIO")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.upPrimary)
                                .kerning(1.2)

                            // White card
                            VStack(spacing: 12) {
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 40, weight: .semibold))
                                    .foregroundStyle(Color(hex: "00f0ff"))

                                Text("Universidad")
                                    .font(.headline)
                                    .foregroundStyle(Color.black)

                                if let qrImage = generateQRImage(from: sticker.qrContent) {
                                    Image(uiImage: qrImage)
                                        .resizable()
                                        .interpolation(.none)
                                        .frame(width: 260, height: 260)
                                        .background(Color.white)
                                } else {
                                    ZStack {
                                        Color.white
                                        Image(systemName: "qrcode.viewfinder")
                                            .font(.system(size: 60))
                                            .foregroundStyle(Color.upPrimary)
                                    }
                                    .frame(width: 260, height: 260)
                                }

                                Text(viewModel.userName ?? "Estudiante")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(Color.black)

                                Text("VÁLIDO 2025–2026")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }
                            .padding(24)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)

                            HStack(spacing: 8) {
                                GlowingDot(color: .upSecondary, size: 6)
                                Text("Permiso Activo")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.upSecondary)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(Color.upSecondary.opacity(0.15))
                            .clipShape(Capsule())
                            .frame(maxWidth: .infinity, alignment: .center)

                            Button(action: { viewModel.stickerPermit = nil }) {
                                Text("Actualizar pegatina")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .foregroundStyle(Color.upTextSecondary)
                                    .overlay(Capsule().stroke(Color.upOutlineVariant, lineWidth: 1))
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            QRScannerView { qrContent in
                viewModel.saveStickerPermit(qrContent)
                showScanner = false
            }
        }
    }

    private func generateQRImage(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let outputImage = filter.outputImage else { return nil }
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
