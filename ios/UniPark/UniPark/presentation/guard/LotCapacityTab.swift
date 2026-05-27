import SwiftUI
import MapKit

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
                        
                        VStack(spacing: 14) {
                            ForEach(viewModel.lots, id: \.id) { lot in
                                LotCapacityCard(lot: lot)
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
    
    private var geometry: LotGeometry {
        LotGeometry.forLot(named: lot.name)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Map(
                position: .constant(
                    .camera(
                        MapCamera(
                            centerCoordinate: geometry.center,
                            distance: 250,
                            heading: 42,
                            pitch: 0
                        )
                    )
                ),
                interactionModes: []
            ) {
                MapPolygon(coordinates: geometry.coordinates)
                    .foregroundStyle(occupancyColor.opacity(0.5))
                    .stroke(Color.upPrimary, lineWidth: 2)

                Annotation(lot.name, coordinate: geometry.center) {
                    Text("\(lot.availableSpots)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.upBackground)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.upSecondary)
                        .clipShape(Capsule())
                        .shadow(color: Color.cyan.opacity(0.35), radius: 6)
                }
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(lot.name)
                        .font(.title3.bold())
                        .foregroundStyle(Color.upTextPrimary)

                    Spacer()

                    Text("\(lot.availableSpots) libres / \(lot.capacityTotal) total")
                        .font(.subheadline)
                        .foregroundStyle(Color.upTextSecondary)
                        .multilineTextAlignment(.trailing)
                }

                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.upSurfaceHighest)
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(occupancyColor)
                                .frame(width: proxy.size.width * CGFloat(lot.occupancyPercentage), height: 6)
                        }
                    }
                    .frame(height: 6)

                    HStack {
                        Text(String(format: "%.0f%% ocupación", lot.occupancyPercentage * 100))
                            .font(.caption)
                            .foregroundStyle(Color.upTextSecondary)
                        
                        Spacer()
                        
                        if lot.isFull {
                            Text("LLENO")
                                .font(.caption.bold())
                                .foregroundStyle(Color.upError)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.upError.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(16)
        }
        .glassCard(cornerRadius: 18, glowColor: occupancyColor)
    }
    
    private var occupancyColor: Color {
        if lot.occupancyPercentage < 0.7 {
            return .upSecondary
        } else if lot.occupancyPercentage < 0.9 {
            return .orange
        } else {
            return .upError
        }
    }
}

private struct LotGeometry {
    let center: CLLocationCoordinate2D
    let coordinates: [CLLocationCoordinate2D]

    static func forLot(named name: String) -> LotGeometry {
        switch name {
        case "Parqueo Key":
            return LotGeometry(
                center: CLLocationCoordinate2D(latitude: 13.680524, longitude: -89.253714),
                coordinates: [
                    CLLocationCoordinate2D(latitude: 13.680210122389441, longitude: -89.25347279543529),
                    CLLocationCoordinate2D(latitude: 13.680272017660446, longitude: -89.25334539050634),
                    CLLocationCoordinate2D(latitude: 13.680879241990954, longitude: -89.25377521450173),
                    CLLocationCoordinate2D(latitude: 13.680839498816082, longitude: -89.25390060777389),
                    CLLocationCoordinate2D(latitude: 13.680592774238331, longitude: -89.25393748571777),
                    CLLocationCoordinate2D(latitude: 13.680555522984136, longitude: -89.25392379323479),
                    CLLocationCoordinate2D(latitude: 13.680348867120747, longitude: -89.25376313476218),
                    CLLocationCoordinate2D(latitude: 13.680454412412706, longitude: -89.25359608646397),
                ]
            )
        case "Parqueo Matías":
            return LotGeometry(
                center: CLLocationCoordinate2D(latitude: 13.680100, longitude: -89.254309),
                coordinates: [
                    CLLocationCoordinate2D(latitude: 13.680323974054101, longitude: -89.25411001529224),
                    CLLocationCoordinate2D(latitude: 13.680324679516982, longitude: -89.25450644457504),
                    CLLocationCoordinate2D(latitude: 13.679876004700510, longitude: -89.25447159364909),
                    CLLocationCoordinate2D(latitude: 13.679879532021591, longitude: -89.25416156562022),
                ]
            )
        default:
            return LotGeometry(
                center: CLLocationCoordinate2D(latitude: 13.680524, longitude: -89.253714),
                coordinates: []
            )
        }
    }
}
