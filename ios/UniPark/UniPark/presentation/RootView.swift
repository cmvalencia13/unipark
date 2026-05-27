import SwiftUI

public struct RootView: View {
    private let devMode: Bool = true
    // TODO: set devMode = false when Keycloak is configured
    @State private var isAuthenticated: Bool = false
    @State private var currentUser: User? = nil

    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                if devMode {
                    let devRole: UserRole = .driver
                    switch devRole {
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
                } else if isAuthenticated, let role = currentUser?.role {
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
                } else {
                    LoginView()
                }
            }
        }
        .onAppear {
            guard !devMode else {
                currentUser = User(
                    email: "test@universidad.edu",
                    fullName: "Carlos Test",
                    role: .driver,
                    universityId: "DEV-000",
                    active: true
                )
                isAuthenticated = true
                return
            }

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

            WalletView()
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
