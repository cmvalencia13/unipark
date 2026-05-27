import SwiftUI

public struct RootView: View {
    private let devMode: Bool = true
    @State private var isAuthenticated: Bool = false
    @State private var currentUser: User? = nil

    public init() {}

    public var body: some View {
        Group {
            if devMode {
                driverTabs
            } else if isAuthenticated, let role = currentUser?.role {
                switch role {
                case .driver:        driverTabs
                case .securityGuard: guardTabs
                case .admin:         Text("Admin View - Coming Soon")
                case .superadmin:    Text("Superadmin View - Coming Soon")
                }
            } else {
                NavigationStack { LoginView() }
            }
        }
        .onAppear {
            guard !devMode else { return }
            let user = OIDCAuthManager.shared.currentUser()
            currentUser = user
            isAuthenticated = user != nil
        }
        .onReceive(NotificationCenter.default.publisher(for: .oidcAuthStateDidChange)) { notification in
            if let user = notification.userInfo?["user"] as? User {
                currentUser = user
                isAuthenticated = true
            }
        }
    }

    // MARK: - Driver Tabs
    private var driverTabs: some View {
        TabView {
            Tab("Status", systemImage: "chart.bar.fill") {
                DriverDashboardView()
            }
            Tab("Map", systemImage: "map.fill") {
                mapPlaceholder
            }
            Tab("Permits", systemImage: "doc.text.fill") {
                Text("Permits coming soon")
                    .foregroundStyle(Color.upTextSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.upBackground)
            }
            Tab("Access", systemImage: "qrcode.viewfinder") {
                DigitalPassView()
            }
        }
        .tint(Color.upPrimary)
    }

    // MARK: - Guard Tabs
    private var guardTabs: some View {
        TabView {
            Tab("Scanner", systemImage: "qrcode.viewfinder") {
                ScannerView()
            }
            Tab("Lotes", systemImage: "car.2.fill") {
                LotCapacityView()
            }
            Tab("Violación", systemImage: "exclamationmark.triangle.fill") {
                ViolationFormView()
            }
        }
        .tint(Color.upPrimary)
    }

    private var mapPlaceholder: some View {
        Text("Map coming soon")
            .foregroundStyle(Color.upTextSecondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.upBackground)
    }
}
