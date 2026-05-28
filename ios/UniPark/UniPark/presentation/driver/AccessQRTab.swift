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
            Color.upBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                UniParkHeader {
                    NotificationCenter.default.post(name: Notification.Name("signOut"), object: nil)
                }
                
                Spacer()
                
                Text(viewModel.currentTime)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.upPrimary)
                
                Text(viewModel.currentDate)
                    .font(.subheadline)
                    .foregroundStyle(Color.upTextSecondary)
                
                Spacer(minLength: 16)
                
                // QR Card (tappable)
                Button(action: { qrExpanded = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 20)
                        
                        VStack(spacing: 8) {
                            if let qrImage = qrImage {
                                Image(uiImage: qrImage)
                                    .resizable()
                                    .interpolation(.none)
                                    .frame(width: 260, height: 260)
                            } else {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 80, weight: .semibold))
                                    .foregroundStyle(Color.upSurface)
                            }
                            
                            Text("Toca para ampliar")
                                .font(.caption)
                                .foregroundStyle(Color.upTextSecondary)
                        }
                        .padding(20)
                    }
                    .frame(width: 300)
                }
                .buttonStyle(.plain)
                
                Text("Expira en \(viewModel.passCountdown)s")
                    .font(.headline)
                    .foregroundStyle(Color.upPrimary)
                    .padding(.top, 12)
                
                Spacer()
                
                // Last scan result
                if let result = viewModel.lastScanResult {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(Color.upSecondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.direction == .entry ? "Entrada registrada" : "Salida registrada")
                                .font(.headline)
                                .foregroundStyle(Color.upTextPrimary)
                            
                            Text("\(result.lotName) • \(result.timeString)")
                                .font(.subheadline)
                                .foregroundStyle(Color.upTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .glassCard(cornerRadius: 16, glowColor: .upSecondary)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(Color.upSecondary)
                            .frame(width: 4)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                            withAnimation {
                                viewModel.lastScanResult = nil
                            }
                        }
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
        }
        .fullScreenCover(isPresented: $qrExpanded) {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Pase de Acceso")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.white)
                    
                    if let qrImage = qrImage {
                        Image(uiImage: qrImage)
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 340, height: 340)
                            .background(Color.white)
                            .cornerRadius(16)
                    }
                    
                    Text("Expira en \(viewModel.passCountdown)s")
                        .font(.headline)
                        .foregroundStyle(Color.upPrimary)
                    
                    Button(action: { qrExpanded = false }) {
                        Text("Cerrar")
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .overlay(Capsule().stroke(Color.white.opacity(0.4)))
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
        }
        .onAppear {
            viewModel.startTimers()
            generateAndDisplayQR()
        }
        .onDisappear {
            viewModel.stopTimers()
        }
    }
    
    private func generateAndDisplayQR() {
        let payload: [String: Any] = [
            "pass": viewModel.passPayload,
            "exp": Int(Date().addingTimeInterval(60).timeIntervalSince1970),
            "nonce": UUID().uuidString
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: []),
           let jsonString = String(data: data, encoding: .utf8) {
            qrImage = generateQRImage(from: jsonString)
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
        
        let targetSize: CGFloat = 260
        let extent = ciImage.extent.integral
        let scale = min(targetSize / extent.width, targetSize / extent.height)
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaled = ciImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
}
