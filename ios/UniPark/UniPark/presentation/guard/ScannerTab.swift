import SwiftUI

public struct ScannerTab: View {
    @State var viewModel: GuardViewModel

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

                        // MARK: Viewfinder
                        VStack(spacing: 20) {
                            ZStack {
                                Color.black
                                    .frame(width: 280, height: 280)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                // Scan line — solo visible cuando no está verificando
                                if viewModel.scanStatus != .verifying {
                                    AnimatedScanLine()
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
                            }

                            // MARK: Direction Buttons
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
                                        viewModel.isScanCooldown
                                            ? Color.upSurfaceHighest : Color.upSecondary
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .neonGlow(color: viewModel.isScanCooldown ? .clear : .upSecondary)
                                }
                                .disabled(viewModel.isScanCooldown)

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
                                        viewModel.isScanCooldown
                                            ? Color.upTextSecondary : Color.upError
                                    )
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                viewModel.isScanCooldown
                                                    ? Color.upSurfaceHighest : Color.upError,
                                                lineWidth: 1.5
                                            )
                                    )
                                }
                                .disabled(viewModel.isScanCooldown)
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
                detail: outcome.displayDetail,
                lot: viewModel.selectedLot?.name ?? "",
                time: viewModel.lastScanTime ?? ""
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Helpers

    private var bracketColor: Color {
        switch viewModel.scanStatus {
        case .idle:       return Color.upPrimary
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
        // top-left
        p.move(to: CGPoint(x: rect.minX, y: rect.minY + len))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX + len, y: rect.minY))
        // top-right
        p.move(to: CGPoint(x: rect.maxX - len, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + len))
        // bottom-left
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY - len))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + len, y: rect.maxY))
        // bottom-right
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
