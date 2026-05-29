import SwiftUI
import MapKit
import CoreLocation
import Observation

// MARK: - Location Manager
final class LocationPermissionManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAndStart() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.first?.coordinate else { return }
        DispatchQueue.main.async { self.onLocationUpdate?(coord) }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Do not auto-center on user location — only move camera when user taps the location button.
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}

@MainActor
@Observable
final class MapViewModel {
    var cameraPosition: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 13.680524, longitude: -89.253714),
            distance: 220,
            heading: 42,
            pitch: 0
        )
    )

    var lots: [ParkingLot] = ParkingLot.stubs
    var selectedLot: ParkingLot? = nil
    var showLotCard: Bool = false

    func zoneColor(for lot: ParkingLot?) -> Color {
        guard let lot else { return Color.upSecondary.opacity(0.35) }
        let pct = lot.occupancyPercentage
        if pct < 0.7 { return Color.upSecondary.opacity(0.45) }
        if pct < 0.9 { return Color.orange.opacity(0.55) }
        return Color.upError.opacity(0.55)
    }

    var parkingKeyLot: ParkingLot { lots.first(where: { $0.name == "Parqueo Key" }) ?? ParkingLot.stubs[0] }
    var parkingMatiasLot: ParkingLot { lots.first(where: { $0.name == "Parqueo Matías" }) ?? ParkingLot.stubs[1] }
}

public struct MapTab: View {
    var viewModel: DriverViewModel
    @State private var mapVM = MapViewModel()
    @State private var locationManager = LocationPermissionManager()

    public init(viewModel: DriverViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // SATELLITE MAP
            Map(position: $mapVM.cameraPosition) {

                // Outer polygon overlay
                MapPolygon(coordinates: LotZone.parkingKeyOuter.coordinates)
                    .foregroundStyle(
                        mapVM.zoneColor(for: mapVM.parkingKeyLot)
                            .shadow(.drop(color: .black.opacity(0.3), radius: 4))
                    )
                    .stroke(Color.upPrimary, lineWidth: 2)

                // Inner polygon overlay (slightly different shade)
                MapPolygon(coordinates: LotZone.parkingKeyInner.coordinates)
                    .foregroundStyle(mapVM.zoneColor(for: mapVM.parkingKeyLot).opacity(0.7))
                    .stroke(Color.upPrimary.opacity(0.6), lineWidth: 1.5)

                // Parqueo Matías — polygon overlay
                MapPolygon(coordinates: LotZone.parkingMatiasOuter.coordinates)
                    .foregroundStyle(
                        mapVM.zoneColor(for: mapVM.parkingMatiasLot)
                            .shadow(.drop(color: .black.opacity(0.3), radius: 4))
                    )
                    .stroke(Color.upSecondary, lineWidth: 2)

                // Parqueo Matías — annotation marker
                Annotation("Parqueo Matías", coordinate: LotZone.parkingMatiasCenter) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(mapVM.zoneColor(for: mapVM.parkingMatiasLot))
                                .frame(width: 44, height: 44)
                                .shadow(color: Color.upSecondary.opacity(0.5), radius: 8)
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Text("\(mapVM.parkingMatiasLot.availableSpots) libres")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Capsule())
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            mapVM.selectedLot = mapVM.parkingMatiasLot
                            mapVM.showLotCard = true
                        }
                    }
                }

                // Parqueo Key — annotation marker
                Annotation("Parqueo Key", coordinate: CLLocationCoordinate2D(latitude: 13.680524, longitude: -89.253714)) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(mapVM.zoneColor(for: mapVM.parkingKeyLot))
                                .frame(width: 44, height: 44)
                                .shadow(color: Color.upPrimary.opacity(0.5), radius: 8)
                            Image(systemName: "parkingsign")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Text("\(mapVM.parkingKeyLot.availableSpots) libres")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Capsule())
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            mapVM.selectedLot = mapVM.parkingKeyLot
                            mapVM.showLotCard = true
                        }
                    }
                }
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .ignoresSafeArea()

            // HEADER overlaid on top of map
            VStack {
                UniParkHeader(onSignOut: {
                    NotificationCenter.default.post(name: Notification.Name("signOut"), object: nil)
                })
                .background(.ultraThinMaterial)
                Spacer()
            }

            // LOCATION BUTTON — bottom trailing, above tab bar
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        locationManager.requestAndStart()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.upPrimary)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: Color.upPrimary.opacity(0.4), radius: 8)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, mapVM.showLotCard ? 280 : 100)
                    .animation(.spring(), value: mapVM.showLotCard)
                }
            }
            .onAppear {
                locationManager.onLocationUpdate = { coord in
                    withAnimation(.easeInOut(duration: 0.8)) {
                        mapVM.cameraPosition = .camera(MapCamera(
                            centerCoordinate: coord,
                            distance: 400,
                            heading: 0,
                            pitch: 0
                        ))
                    }
                }
            }

            // FLOATING LOT CARD (appears when marker tapped)
            if mapVM.showLotCard, let lot = mapVM.selectedLot {
                LotInfoCard(lot: lot, onDismiss: {
                    withAnimation { mapVM.showLotCard = false }
                })
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            if !viewModel.lots.isEmpty { mapVM.lots = viewModel.lots }
            Task {
                await viewModel.refreshLots()
                mapVM.lots = viewModel.lots
            }
        }
        .onChange(of: viewModel.lots) { _, newLots in
            mapVM.lots = newLots
        }
    }
}

private struct LotInfoCard: View {
    let lot: ParkingLot
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lot.name.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.upPrimary)
                        .kerning(1.2)
                    Text("Campus Universidad")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.upTextPrimary)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.upTextSecondary)
                }
            }

            // Stats row
            HStack(spacing: 0) {
                statItem(value: "\(lot.availableSpots)", label: "Libres",
                         color: lot.isFull ? .upError : .upSecondary)
                Divider().frame(height: 36).background(Color.upOutlineVariant)
                statItem(value: "\(lot.capacityUsed)", label: "Ocupados",
                         color: .upTextPrimary)
                Divider().frame(height: 36).background(Color.upOutlineVariant)
                statItem(value: "\(lot.capacityTotal)", label: "Total",
                         color: .upTextPrimary)
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Ocupación")
                        .font(.caption).foregroundStyle(Color.upTextSecondary)
                    Spacer()
                    Text(String(format: "%.0f%%", lot.occupancyPercentage * 100))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(occupancyColor)
                }
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.upSurfaceHighest).frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(occupancyColor)
                            .frame(width: proxy.size.width * CGFloat(lot.occupancyPercentage), height: 8)
                    }
                }.frame(height: 8)
            }

            if lot.isFull {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Parqueo lleno — busca otro acceso")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.upError)
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 20, glowColor: occupancyColor)
    }

    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.weight(.bold)).foregroundStyle(color)
            Text(label).font(.caption).foregroundStyle(Color.upTextSecondary)
        }.frame(maxWidth: .infinity)
    }

    private var occupancyColor: Color {
        lot.occupancyPercentage < 0.7 ? .upSecondary :
        lot.occupancyPercentage < 0.9 ? .orange : .upError
    }
}
