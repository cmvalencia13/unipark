import SwiftUI

// MARK: - Sticker validity helpers
private func stickerAcademicYearStart() -> Date {
    let cal = Calendar.current
    let now = Date()
    let year = cal.component(.year, from: now)
    let month = cal.component(.month, from: now)
    // Academic year starts Aug 10. If we're before Aug 10 this year, use last year's Aug 10.
    let startYear = month < 8 || (month == 8 && cal.component(.day, from: now) < 10) ? year - 1 : year
    return cal.date(from: DateComponents(year: startYear, month: 8, day: 10))!
}

private func stickerIsValidForCurrentYear(_ permit: StickerPermit?) -> Bool {
    guard let permit else { return false }
    return permit.savedAt >= stickerAcademicYearStart()
}

private func nextStickerRenewalString() -> String {
    let cal = Calendar.current
    let now = Date()
    let year = cal.component(.year, from: now)
    let month = cal.component(.month, from: now)
    let day = cal.component(.day, from: now)
    let renewalYear = (month > 8 || (month == 8 && day >= 10)) ? year + 1 : year
    let fmt = DateFormatter()
    fmt.locale = Locale(identifier: "es_ES")
    fmt.dateFormat = "d 'de' MMMM 'de' yyyy"
    let renewalDate = cal.date(from: DateComponents(year: renewalYear, month: 8, day: 10))!
    return fmt.string(from: renewalDate)
}

// MARK: - Main View
public struct HomeTab: View {
    @State var viewModel: DriverViewModel

    public init(viewModel: DriverViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.upBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Sticky Header
                VStack(alignment: .center, spacing: 4) {
                    Text(viewModel.currentDate)
                        .font(.subheadline)
                        .foregroundStyle(Color.upTextSecondary)
                    Text(viewModel.currentTime)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.upPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.upBackground)

                // MARK: Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {

                        // ── CARD PRINCIPAL ─────────────────────────────────
                        MainStatusCard(viewModel: viewModel)

                        // ── ACCESO RÁPIDO ──────────────────────────────────
                        Button(action: {
                            NotificationCenter.default.post(
                                name: Notification.Name("navigateToAccessTab"), object: nil)
                        }) {
                            Label("Ver mi Pase Digital", systemImage: "qrcode")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .foregroundStyle(Color.upSurfaceLowest)
                                .background(Color.upSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // ── OCUPACIÓN DEL CAMPUS ───────────────────────────
                        OccupancyCard(lots: Array(viewModel.lots.prefix(2)))

                        // ── ALERTA DEL SISTEMA ─────────────────────────────
                        SystemAlertCard()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear { viewModel.startTimers() }
        .onDisappear { viewModel.stopTimers() }
    }
}

// MARK: - Main Status Card (unified)
private struct MainStatusCard: View {
    var viewModel: DriverViewModel

    private var scan: ScanResult? { viewModel.lastEntryScan }
    private var stickerValid: Bool { stickerIsValidForCurrentYear(viewModel.stickerPermit) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Sección superior: última ubicación ──────────────────────
            VStack(alignment: .leading, spacing: 10) {
                Label("ÚLTIMA UBICACIÓN", systemImage: "parkingsign.circle.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.upPrimary)
                    .textCase(.uppercase)
                    .kerning(1.2)

                if let scan {
                    // Nombre del parqueo — destacado
                    Text(scan.lotName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.upTextPrimary)

                    // Spot + dirección
                    HStack(spacing: 8) {
                        Image(systemName: scan.direction == .entry ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .foregroundStyle(scan.direction == .entry ? Color.upSecondary : Color.orange)
                            .font(.system(size: 18))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(scan.detail)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.upTextPrimary)
                            Text(scan.direction == .entry ? "Entrada" : "Salida")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(scan.direction == .entry ? Color.upSecondary : Color.orange)
                        }
                        Spacer()
                        // Hora prominente
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(scan.timeString)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.upTextPrimary)
                            Text("hace")
                                .font(.caption)
                                .foregroundStyle(Color.upTextSecondary)
                        }
                    }
                    .padding(12)
                    .background(Color.upSurfaceHighest)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // Estado vacío
                    HStack(spacing: 10) {
                        Image(systemName: "mappin.slash")
                            .font(.title3)
                            .foregroundStyle(Color.upTextSecondary)
                        Text("Aún no hay registros de entrada")
                            .font(.subheadline)
                            .foregroundStyle(Color.upTextSecondary)
                    }
                    .padding(12)
                    .background(Color.upSurfaceHighest)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(16)

            // ── Divisor ────────────────────────────────────────────────
            Rectangle()
                .fill(Color.upSurfaceHighest)
                .frame(height: 1)
                .padding(.horizontal, 16)

            // ── Sección inferior: estado de pegatina ───────────────────
            HStack(spacing: 10) {
                Image(systemName: "sticker")
                    .font(.system(size: 22))
                    .foregroundStyle(stickerValid ? Color.upSecondary : Color.upTextSecondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Pegatina de parqueo")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.upTextPrimary)
                    Text(stickerValid
                         ? "Válida · Renueva el \(nextStickerRenewalString())"
                         : "Sin registrar · Escanéala en la pestaña Permiso")
                        .font(.caption)
                        .foregroundStyle(Color.upTextSecondary)
                        .lineLimit(2)
                }

                Spacer()

                // Chip de estado
                HStack(spacing: 5) {
                    GlowingDot(color: stickerValid ? .upSecondary : .gray, size: 5)
                    Text(stickerValid ? "Válida" : "Pendiente")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(stickerValid ? Color.upSecondary : Color.upTextSecondary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background((stickerValid ? Color.upSecondary : Color.gray).opacity(0.15))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .glassCard(cornerRadius: 18, glowColor: .upPrimary)
    }
}

// MARK: - Occupancy Card
private struct OccupancyCard: View {
    let lots: [ParkingLot]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OCUPACIÓN DEL CAMPUS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.upPrimary)
                .textCase(.uppercase)
                .kerning(1.2)

            ForEach(lots, id: \.id) { lot in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(lot.name)
                            .font(.subheadline)
                            .foregroundStyle(Color.upTextPrimary)
                        Spacer()
                        Text("\(lot.capacityUsed)/\(lot.capacityTotal)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.upPrimary)
                    }
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.upSurfaceHighest)
                                .frame(height: 7)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(lot.occupancyPercentage > 0.85 ? Color.red :
                                      lot.occupancyPercentage > 0.6  ? Color.orange : Color.upSecondary)
                                .frame(width: max(0, proxy.size.width * CGFloat(lot.occupancyPercentage)), height: 7)
                        }
                    }
                    .frame(height: 7)
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 16, glowColor: .clear)
    }
}

// MARK: - System Alert Card
private struct SystemAlertCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(Color.orange)
                .padding(8)
                .background(Color.upSurfaceHighest)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text("ALERTAS DEL SISTEMA")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.upPrimary)
                    .textCase(.uppercase)
                    .kerning(1.2)
                Text("Mantenimiento programado en Lote C. Algunos espacios estarán cerrados.")
                    .font(.subheadline)
                    .foregroundStyle(Color.upTextSecondary)
                Text("HACE 4 HORAS")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.upTextSecondary)
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 16, glowColor: .clear)
    }
}
