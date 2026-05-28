import SwiftUI

// MARK: - Sticker validity helpers
private func stickerAcademicYearStart() -> Date {
    let cal = Calendar.current
    let now = Date()
    let year = cal.component(.year, from: now)
    let month = cal.component(.month, from: now)
    let day = cal.component(.day, from: now)
    let startYear = (month < 8 || (month == 8 && day < 10)) ? year - 1 : year
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
    fmt.dateFormat = "d MMM yyyy"
    let date = cal.date(from: DateComponents(year: renewalYear, month: 8, day: 10))!
    return fmt.string(from: date)
}

// MARK: - Home Tab
public struct HomeTab: View {
    @State var viewModel: DriverViewModel

    public init(viewModel: DriverViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.upBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── App Header ─────────────────────────────────────────
                StitchHeader(
                    currentDate: viewModel.currentDate,
                    currentTime: viewModel.currentTime
                )

                // ── Scrollable Content ──────────────────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Card principal — última ubicación + pegatina
                        StitchStatusCard(viewModel: viewModel)

                        // Botón QR — píldora mint
                        StitchQRButton()

                        // Ocupación del campus
                        StitchOccupancyCard(lots: Array(viewModel.lots.prefix(2)))

                        // Alerta del sistema
                        StitchAlertCard()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 100) // espacio para tab bar flotante
                }
            }
        }
        .onAppear { viewModel.startTimers() }
        .onDisappear { viewModel.stopTimers() }
    }
}

// MARK: - Header (avatar + nombre + hora + campana)
private struct StitchHeader: View {
    let currentDate: String
    let currentTime: String

    var body: some View {
        VStack(spacing: 0) {
            // Top bar: avatar + UniPark + campana
            HStack {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: "#1e2024"))
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.upPrimary)
                }

                Text("UniPark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.upPrimary)
                    .tracking(-0.3)

                Spacer()

                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#1a1c20"))
                            .frame(width: 40, height: 40)
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.upPrimary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Fecha y hora
            VStack(spacing: 4) {
                Text(currentDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.upTextSecondary)
                    .textCase(.uppercase)
                    .kerning(0.5)

                Text(currentTime)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(Color.upPrimary)
                    .tracking(-1.5)
            }
            .padding(.vertical, 8)
        }
        .background(Color.upBackground)
    }
}

// MARK: - Status Card principal (diseño Stitch)
private struct StitchStatusCard: View {
    var viewModel: DriverViewModel
    private var scan: ScanResult? { viewModel.lastEntryScan }
    private var stickerValid: Bool { stickerIsValidForCurrentYear(viewModel.stickerPermit) }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Watermark — ícono de parqueo decorativo
            Image(systemName: "parkingsign")
                .font(.system(size: 90, weight: .black))
                .foregroundStyle(Color.upPrimary.opacity(0.07))
                .padding(20)

            VStack(alignment: .leading, spacing: 0) {

                // ── Encabezado: pulse dot + label ──────────────────────
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.upPrimary)
                        .frame(width: 8, height: 8)
                        .shadow(color: Color.upPrimary.opacity(0.8), radius: 4)

                    Text("ÚLTIMA UBICACIÓN")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.upPrimary)
                        .kerning(1.2)
                }
                .padding(.bottom, 12)

                // ── Nombre del parqueo ─────────────────────────────────
                Text(scan?.lotName ?? "Sin ubicación reciente")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.upTextPrimary)
                    .tracking(-0.3)
                    .padding(.bottom, 16)

                // ── Row de entrada + hora ──────────────────────────────
                HStack(spacing: 14) {
                    // Ícono dirección
                    ZStack {
                        Circle()
                            .fill(Color.upSecondary.opacity(0.18))
                            .frame(width: 44, height: 44)
                        Image(systemName: scan?.direction == .entry
                              ? "arrow.up" : "arrow.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(scan?.direction == .entry
                                             ? Color.upSecondary : Color.orange)
                    }

                    // Detalle
                    VStack(alignment: .leading, spacing: 3) {
                        if let scan {
                            HStack(spacing: 6) {
                                Text(scan.detail)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.upTextPrimary)
                            }
                            Text(scan.direction == .entry ? "Entrada" : "Salida")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(scan.direction == .entry
                                                 ? Color.upSecondary : Color.orange)
                                .kerning(0.5)
                        } else {
                            Text("Aún no hay registros")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.upTextSecondary)
                        }
                    }

                    Spacer()

                    // Hora — prominente
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(scan?.timeString ?? "—")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Color.upTextPrimary)
                        Text("hace")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.upTextSecondary)
                            .kerning(0.3)
                    }
                }
                .padding(14)
                .background(Color(hex: "#0c0e12").opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 16)

                // ── Divisor ────────────────────────────────────────────
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)
                    .padding(.bottom, 14)

                // ── Pegatina (sección secundaria) ──────────────────────
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(stickerValid ? Color.upSecondary : Color.upTextSecondary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pegatina de parqueo")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.upTextPrimary)
                        Text(stickerValid
                             ? "Válida · Renueva \(nextStickerRenewalString())"
                             : "Sin registrar · Escanéala en Permiso")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.upTextSecondary)
                    }

                    Spacer()

                    // Chip Pendiente / Válida
                    Text(stickerValid ? "Válida" : "Pendiente")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.upTextSecondary.opacity(0.7))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: "#282a2e"))
                        .clipShape(Capsule())
                }
            }
            .padding(22)
        }
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(hex: "#1c1f26").opacity(0.85))
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                )
                .shadow(color: Color.upPrimary.opacity(0.15), radius: 20, x: 0, y: 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}

// MARK: - Botón QR (píldora mint)
private struct StitchQRButton: View {
    var body: some View {
        Button(action: {
            NotificationCenter.default.post(
                name: Notification.Name("navigateToAccessTab"), object: nil)
        }) {
            HStack(spacing: 10) {
                Image(systemName: "qrcode")
                    .font(.system(size: 18, weight: .semibold))
                Text("Ver mi Pase Digital")
                    .font(.system(size: 13, weight: .bold))
                    .kerning(0.2)
            }
            .foregroundStyle(Color(hex: "#003828"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.upSecondary)
            .clipShape(Capsule())
            .shadow(color: Color.upSecondary.opacity(0.25), radius: 12, x: 0, y: 4)
        }
    }
}

// MARK: - Ocupación del campus (barras con gradiente + glow)
private struct StitchOccupancyCard: View {
    let lots: [ParkingLot]

    private func barGradient(for pct: Double) -> LinearGradient {
        if pct > 0.75 {
            return LinearGradient(colors: [Color(hex: "#ffb874"), Color.red],
                                  startPoint: .leading, endPoint: .trailing)
        } else if pct > 0.5 {
            return LinearGradient(colors: [Color.orange, Color(hex: "#ffb874")],
                                  startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [Color.upSecondary, Color.upPrimary],
                                  startPoint: .leading, endPoint: .trailing)
        }
    }

    private func glowColor(for pct: Double) -> Color {
        pct > 0.75 ? .red : (pct > 0.5 ? .orange : Color.upSecondary)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("OCUPACIÓN DEL CAMPUS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.upPrimary)
                .kerning(1.2)

            ForEach(lots, id: \.id) { lot in
                VStack(spacing: 10) {
                    HStack(alignment: .lastTextBaseline) {
                        Text(lot.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.upTextPrimary)
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("\(lot.capacityUsed)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(glowColor(for: lot.occupancyPercentage))
                            Text("/ \(lot.capacityTotal)")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.upTextSecondary)
                        }
                    }

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "#333539"))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(barGradient(for: lot.occupancyPercentage))
                                .frame(width: max(4, proxy.size.width * CGFloat(lot.occupancyPercentage)),
                                       height: 8)
                                .shadow(color: glowColor(for: lot.occupancyPercentage).opacity(0.6),
                                        radius: 4, x: 0, y: 0)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(hex: "#1c1f26").opacity(0.85))
                .background(RoundedRectangle(cornerRadius: 28).fill(.ultraThinMaterial))
        )
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.06), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}

// MARK: - Alerta del sistema
private struct StitchAlertCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#ffd1a9").opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: "#ffb874"))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("ALERTAS DEL SISTEMA")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: "#ffb874"))
                    .kerning(1.2)
                Text("Mantenimiento programado en Lote C. Algunos espacios estarán cerrados.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.upTextSecondary)
                    .lineSpacing(2)
                Text("HACE 4 HORAS")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.upTextSecondary.opacity(0.5))
                    .kerning(0.5)
            }
        }
        .padding(18)
        .background(Color(hex: "#1a1c20"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

