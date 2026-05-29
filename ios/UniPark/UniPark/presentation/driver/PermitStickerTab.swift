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
                    // MARK: Empty state
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            Spacer(minLength: 40)

                            // Preview del sticker estilo físico (sin QR real)
                            StickerCard(qrImage: nil, userName: viewModel.userName ?? "Estudiante", isPreview: true)
                                .opacity(0.45)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "qrcode.viewfinder")
                                            .font(.system(size: 36, weight: .semibold))
                                            .foregroundStyle(.white)
                                        Text("Escanea tu pegatina")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.white)
                                    }
                                )

                            Text("Escanea la pegatina física del parabrisas una sola vez para tenerla disponible digitalmente en tu perfil.")
                                .font(.subheadline)
                                .foregroundStyle(Color.upTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)

                            Button(action: { showScanner = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "camera.viewfinder")
                                    Text("Escanear Pegatina Física")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .foregroundStyle(.black)
                                .background(Color.upSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            Text("Solo necesitas hacerlo una vez. Se guardará en tu perfil.")
                                .font(.caption)
                                .foregroundStyle(Color.upTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                    }
                } else if let sticker = viewModel.stickerPermit {
                    // MARK: Display sticker
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            Text("PERMISO DE PARQUEO")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.upPrimary)
                                .kerning(1.4)
                                .padding(.top, 20)

                            StickerCard(
                                qrImage: generateQRImage(from: sticker.qrContent),
                                userName: viewModel.userName ?? "Estudiante",
                                isPreview: false
                            )

                            // Status pill
                            HStack(spacing: 6) {
                                Circle().fill(Color.upSecondary).frame(width: 8, height: 8)
                                Text("Permiso Activo · \(academicYearString())")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.upSecondary)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Color.upSecondary.opacity(0.12))
                            .clipShape(Capsule())

                            // Validity info
                            HStack(spacing: 16) {
                                Label("Año académico 2025–2026", systemImage: "calendar")
                                    .font(.caption)
                                    .foregroundStyle(Color.upTextSecondary)
                            }

                            Divider().padding(.horizontal, 16)

                            Button(action: { showScanner = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Actualizar pegatina")
                                }
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundStyle(Color.upTextSecondary)
                                .overlay(Capsule().stroke(Color.upOutlineVariant, lineWidth: 1))
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.horizontal, 20)
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

    private func academicYearString() -> String {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let startYear = (month >= 8) ? year : year - 1
        return "\(startYear)–\(startYear + 1)"
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

// MARK: - Sticker Card (replica visual de la pegatina física)

private struct StickerCard: View {
    let qrImage: UIImage?
    let userName: String
    let isPreview: Bool

    var body: some View {
        ZStack {
            // Fondo oscuro con borde redondeado — igual que el sticker físico
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                )

            VStack(spacing: 10) {
                // Header "PARKING PASS" estilo pegatina
                VStack(spacing: 2) {
                    Text("PARKING")
                        .font(.system(size: 22, weight: .black, design: .default))
                        .foregroundStyle(.white)
                        .kerning(4)
                    Text("PASS")
                        .font(.system(size: 22, weight: .black, design: .default))
                        .foregroundStyle(.white)
                        .kerning(4)
                }
                .padding(.top, 20)

                // QR con tinte azul — replica el QR azul del sticker físico
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.05, green: 0.05, blue: 0.15))
                        .frame(width: 200, height: 200)

                    if let qrImage {
                        Image(uiImage: qrImage)
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 180, height: 180)
                            .colorMultiply(Color(red: 0.2, green: 0.5, blue: 1.0))
                    } else {
                        Image(systemName: "qrcode")
                            .font(.system(size: 80))
                            .foregroundStyle(Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.4))
                    }
                }

                // Año — igual que "2026" en el sticker
                Text("2026")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))
                    .kerning(2)

                // Sub-texto branding
                Text("THE DO GENERATION")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color(red: 0.2, green: 0.5, blue: 1.0))
                    .kerning(1.5)
                    .padding(.bottom, 16)
            }
        }
        .frame(width: 240, height: 320)
        .shadow(color: Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.3), radius: 20, x: 0, y: 8)
    }
}
