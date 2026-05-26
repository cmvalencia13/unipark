import SwiftUI

public struct RootView: View {
    private let role: UserRole = .securityGuard

    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                switch role {
                case .driver:
                    driverTabs
                case .securityGuard:
                    guardTabs
                case .admin:
                    Text("Admin View - Coming Soon")
                        .font(.title)
                case .superadmin:
                    Text("Superadmin View - Coming Soon")
                        .font(.title)
                }
            }
        }
    }

    // MARK: - Tabs

    private var driverTabs: some View {
        TabView {
            DriverDashboardView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }

            DigitalPassView()
                .tabItem {
                    Label("Mi Pase", systemImage: "qrcode")
                }

            Text("Wallet - Coming Soon")
                .font(.title)
                .tabItem {
                    Label("Wallet", systemImage: "creditcard.fill")
                }
        }
    }

    private var guardTabs: some View {
        TabView {
            ScannerView()
                .tabItem {
                    Label("Scanner", systemImage: "qrcode.viewfinder")
                }

            LotCapacityView()
                .tabItem {
                    Label("Lotes", systemImage: "car.2.fill")
                }

            ViolationFormView()
                .tabItem {
                    Label("Violación", systemImage: "exclamationmark.triangle")
                }
        }
    }
}
