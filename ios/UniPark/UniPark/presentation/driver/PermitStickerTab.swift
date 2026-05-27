import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

public struct PermitStickerTab: View {
    @State var viewModel: DriverViewModel
    @State private var showScanner = false
    
    public init(viewModel: DriverViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color.upBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                UniParkHeader {
                    NotificationCenter.default.post(name: Notification.Name("signOut"), object: nil)
                }
                
                if viewModel.stickerPermit == nil {
                    // State A — Empty
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
                    // State B — Display Permit
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            Text("PERMISO UNIVERSITARIO")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.upPrimary)
                                .textCase(.uppercase)
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
                                    .foregroundStyle(Color.upSurfaceLowest)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.upSecondary)
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
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            StickerScannerSheet { qrContent in
                viewModel.saveStickerPermit(qrContent)
                showScanner = false
            }
        }
    }
    
    private func generateQRImage(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(Data(string.utf8), forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard var ciImage = filter.outputImage else {
            return nil
        }
        
        let scale = 260 / ciImage.extent.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaled = ciImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
}

private struct StickerScannerSheet: View {
    let onScanned: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.upBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Apunta al QR de tu pegatina")
                        .font(.headline)
                        .foregroundStyle(Color.upTextPrimary)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.upOutlineVariant, lineWidth: 1))
                        
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 60, weight: .semibold))
                            .foregroundStyle(Color.upPrimary)
                    }
                    .frame(height: 280)
                    
                    Button(action: { onScanned("UNIPARK-2025-DEMO-QR") }) {
                        Text("Simular escaneo")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundStyle(Color.upSurfaceLowest)
                            .background(Color.upPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.upTextSecondary)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
