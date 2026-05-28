import SwiftUI

public struct HomeTab: View {
    @State var viewModel: DriverViewModel
    @State private var dateTimer: Timer?
    
    public init(viewModel: DriverViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color.upBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Sticky Header
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
                
                // MARK: - Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Card 1 — Active Permit
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PERMISO ACTIVO")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.upPrimary)
                                .textCase(.uppercase)
                                .kerning(1.2)
                            
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(viewModel.activePass?.lotName ?? "Commuter Zone A")
                                        .font(.title.bold())
                                        .foregroundStyle(Color.upTextPrimary)
                                    
                                    Text("Expiry: \(viewModel.activePass?.expiryDateString ?? "Dic 31, 2026")")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.upTextSecondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    HStack(spacing: 8) {
                                        GlowingDot(color: .upSecondary, size: 6)
                                        Text("Permiso Válido")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(Color.upSurfaceLowest)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.upSecondary)
                                    .clipShape(Capsule())
                                    
                                    Button(action: {}) {
                                        HStack(spacing: 6) {
                                            Text("Gestionar")
                                                .font(.subheadline.weight(.semibold))
                                            Image(systemName: "chevron.right")
                                        }
                                        .foregroundStyle(Color.upPrimary)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 16, glowColor: .upPrimary)
                        
                        // Card 2 — Last Entry Scan
                        if let scan = viewModel.lastEntryScan {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("ÚLTIMA ENTRADA ESCANEADA")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.upPrimary)
                                    .textCase(.uppercase)
                                    .kerning(1.2)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(scan.lotName)
                                        .font(.title2.bold())
                                        .foregroundStyle(Color.upTextPrimary)
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.upSecondary)
                                        
                                        Text("Escaneado a las \(scan.timeString) • \(scan.detail)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.upTextSecondary)
                                    }
                                }
                            }
                            .padding(16)
                            .glassCard(cornerRadius: 16, glowColor: .upSecondary)
                        }
                        
                        // Card 3 — Quick Action
                        Button(action: {
                            NotificationCenter.default.post(name: Notification.Name("navigateToAccessTab"), object: nil)
                        }) {
                            Label("Ver mi Pase Digital", systemImage: "qrcode")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundStyle(Color.upSurfaceLowest)
                                .background(Color.upSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.vertical, 4)
                        
                        // Card 4 — Campus Occupancy
                        VStack(alignment: .leading, spacing: 12) {
                            Text("OCUPACIÓN DEL CAMPUS")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.upPrimary)
                                .textCase(.uppercase)
                                .kerning(1.2)
                            
                            ForEach(Array(viewModel.lots.prefix(2)), id: \.id) { lot in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(lot.name)
                                            .font(.subheadline)
                                            .foregroundStyle(Color.upTextPrimary)
                                        Spacer()
                                        Text(String(format: "%.0f%% lleno", lot.occupancyPercentage * 100))
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(Color.upPrimary)
                                    }
                                    
                                    GeometryReader { proxy in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.upSurfaceHighest)
                                                .frame(height: 8)
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.upSecondary)
                                                .frame(width: max(0, proxy.size.width * CGFloat(lot.occupancyPercentage)), height: 8)
                                        }
                                    }
                                    .frame(height: 8)
                                }
                            }
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 16, glowColor: .clear)
                        
                        // Card 5 — Alerts
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.orange)
                                    .padding(8)
                                    .background(Color.upSurfaceHighest)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 6) {
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
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 16, glowColor: .clear)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            viewModel.startTimers()
        }
        .onDisappear {
            viewModel.stopTimers()
        }
    }
}
