import SwiftUI

public struct ScannerTab: View {
    @State var viewModel: GuardViewModel
    
    public init(viewModel: GuardViewModel) {
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Lot Selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.lots, id: \.id) { lot in
                                    Button(action: {
                                        viewModel.selectedLotId = lot.id
                                    }) {
                                        Text(lot.name)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(
                                                lot.id == viewModel.selectedLotId ? Color.upBackground : Color.upTextPrimary
                                            )
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                lot.id == viewModel.selectedLotId ? Color.upPrimary : Color.upSurface
                                            )
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Viewfinder Scanner
                        VStack(spacing: 20) {
                            ZStack {
                                // Black background
                                Color.black
                                    .frame(width: 280, height: 280)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                // Animated scan line
                                VStack(spacing: 0) {
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.upPrimary.opacity(0),
                                            Color.upPrimary,
                                            Color.upPrimary.opacity(0)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 2)
                                }
                                .frame(width: 280, height: 280)
                                .offset(y: AnimatedScanLine().offset)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                // Corner brackets
                                ScanCornerBrackets()
                                    .stroke(Color.upPrimary, lineWidth: 2)
                                    .frame(width: 280, height: 280)
                            }
                            
                            // Direction buttons
                            HStack(spacing: 12) {
                                Button(action: {
                                    viewModel.processScan(direction: .entry)
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.right.circle.fill")
                                        Text("ENTRADA")
                                            .font(.caption.weight(.bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .foregroundStyle(Color.upBackground)
                                    .background(Color.upSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .neonGlow(color: Color.upSecondary)
                                }
                                
                                Button(action: {
                                    viewModel.processScan(direction: .exit)
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.left.circle")
                                        Text("SALIDA")
                                            .font(.caption.weight(.bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .foregroundStyle(Color.upError)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.upError, lineWidth: 1.5)
                                    )
                                }
                            }
                            
                            // Scan result card (appears when scanStatus != .idle)
                            if case .success(let driver) = viewModel.scanStatus {
                                ScanResultCard(
                                    icon: "checkmark.circle.fill",
                                    iconColor: .upSecondary,
                                    direction: "ENTRADA",
                                    driver: driver,
                                    lot: viewModel.selectedLot?.name ?? "Desconocido",
                                    time: viewModel.lastScanTime ?? ""
                                )
                            } else if case .rejected(let reason) = viewModel.scanStatus {
                                ScanResultCard(
                                    icon: "xmark.circle.fill",
                                    iconColor: .upError,
                                    direction: "RECHAZADO",
                                    driver: reason,
                                    lot: "Error de acceso",
                                    time: viewModel.lastScanTime ?? ""
                                )
                            } else if viewModel.scanStatus == .pending {
                                HStack(spacing: 12) {
                                    ProgressView()
                                        .tint(Color.upPrimary)
                                    Text("Escaneando...")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.upTextSecondary)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.upSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "--:--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

private struct AnimatedScanLine: View {
    @State private var isAnimating = false
    
    var offset: CGFloat {
        isAnimating ? 120 : -120
    }
    
    var body: some View {
        Color.clear
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

private struct ScanCornerBrackets: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bracketLength: CGFloat = 20
        let cornerRadius: CGFloat = 4
        
        // Top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + bracketLength))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + bracketLength, y: rect.minY))
        
        // Top-right
        path.move(to: CGPoint(x: rect.maxX - bracketLength, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + bracketLength))
        
        // Bottom-left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - bracketLength))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + bracketLength, y: rect.maxY))
        
        // Bottom-right
        path.move(to: CGPoint(x: rect.maxX - bracketLength, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bracketLength))
        
        return path
    }
}

private struct ScanResultCard: View {
    let icon: String
    let iconColor: Color
    let direction: String
    let driver: String
    let lot: String
    let time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(direction)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.upTextSecondary)
                    
                    Text(driver)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.upTextPrimary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                Label(lot, systemImage: "building.2.fill")
                    .font(.caption)
                    .foregroundStyle(Color.upTextSecondary)
                
                Label(time, systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(Color.upTextSecondary)
            }
        }
        .padding(12)
        .background(Color.upSurface)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(iconColor, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
