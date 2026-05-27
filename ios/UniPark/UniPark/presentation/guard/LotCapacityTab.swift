import SwiftUI

public struct LotCapacityTab: View {
    @State var viewModel: GuardViewModel
    @State private var refreshTimer: Timer?
    
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
                    VStack(alignment: .leading, spacing: 16) {
                        Text("CAPACIDAD DE LOTES")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.upPrimary)
                            .textCase(.uppercase)
                            .kerning(1.2)
                            .padding(.top, 16)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(viewModel.lots, id: \.id) { lot in
                                LotCapacityCard(
                                    lot: lot,
                                    isSelected: lot.id == viewModel.selectedLotId,
                                    onSelect: {
                                        viewModel.selectedLotId = lot.id
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            startRefreshTimer()
        }
        .onDisappear {
            refreshTimer?.invalidate()
        }
    }
    
    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            // Simulate API refresh — lots remain as-is (no-op for now)
        }
    }
}

private struct LotCapacityCard: View {
    let lot: ParkingLot
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(lot.name)
                        .font(.headline)
                        .foregroundStyle(Color.upTextPrimary)
                    
                    Text("\(lot.capacityUsed)/\(lot.capacityTotal)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(occupancyColor(lot))
                    
                    Text("\(lot.availableSpots) libres")
                        .font(.subheadline)
                        .foregroundStyle(Color.upTextSecondary)
                    
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.upSurfaceHighest)
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(occupancyColor(lot))
                                .frame(width: proxy.size.width * CGFloat(lot.occupancyPercentage), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if lot.isFull {
                    Text("LLENO")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.upError)
                        .clipShape(Capsule())
                        .padding(8)
                }
            }
            .glassCard(cornerRadius: 16, glowColor: isSelected ? occupancyColor(lot) : .clear)
            .overlay(
                isSelected ?
                RoundedRectangle(cornerRadius: 16)
                    .stroke(occupancyColor(lot), lineWidth: 2) : nil
            )
        }
        .buttonStyle(.plain)
    }
    
    private func occupancyColor(_ lot: ParkingLot) -> Color {
        if lot.occupancyPercentage < 0.7 {
            return .upSecondary
        } else if lot.occupancyPercentage < 0.9 {
            return .orange
        } else {
            return .upError
        }
    }
}
