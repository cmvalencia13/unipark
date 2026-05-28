import SwiftUI

public struct RootView: View {
    @State private var isAuthenticated: Bool = false
    @State private var currentUser: User? = nil
    @State private var isLoading: Bool = true
    @State private var driverVM = DriverViewModel()
    @State private var guardVM  = GuardViewModel()
    @State private var selectedDriverTab: Int = 0

    public init() {}

    public var body: some View {
        Group {
            if isLoading {
                SplashView()
            } else if isAuthenticated, let role = currentUser?.role {
                switch role {
                case .driver:        driverTabs
                case .securityGuard: guardTabs
                case .admin:         AdminPlaceholderView()
                case .superadmin:    SuperadminPlaceholderView()
                }
            } else {
                NavigationStack { LoginView() }
            }
        }
        .onAppear {
            let user = OIDCAuthManager.shared.currentUser()
            currentUser = user
            isAuthenticated = user != nil
            isLoading = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .oidcAuthStateDidChange)) { notification in
            if let user = notification.userInfo?["user"] as? User {
                currentUser = user
                isAuthenticated = true
                // Reiniciar ViewModels con el usuario real
                driverVM = DriverViewModel()
                guardVM  = GuardViewModel()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("signOut"))) { _ in
            Task { try? await OIDCAuthManager.shared.logout() }
            isAuthenticated = false
            currentUser = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("navigateToAccessTab"))) { _ in
            selectedDriverTab = 3
        }
    }

    // MARK: - Driver Tabs
    private var driverTabs: some View {
        TabView(selection: $selectedDriverTab) {
            Tab("Inicio",   systemImage: "house.fill",        value: 0) { HomeTab(viewModel: driverVM) }
            Tab("Mapa",     systemImage: "map.fill",           value: 1) { MapTab(viewModel: driverVM) }
            Tab("Permiso",  systemImage: "qrcode",             value: 2) { PermitStickerTab(viewModel: driverVM) }
            Tab("Acceso",   systemImage: "qrcode.viewfinder",  value: 3) { AccessQRTab(viewModel: driverVM) }
        }
        .tint(Color.upPrimary)
    }

    // MARK: - Guard Tabs
    private var guardTabs: some View {
        TabView {
            Tab("Scanner",      systemImage: "qrcode.viewfinder")             { ScannerTab(viewModel: guardVM) }
            Tab("Lotes",        systemImage: "car.2.fill")                    { LotCapacityTab(viewModel: guardVM) }
            Tab("Infracciones", systemImage: "exclamationmark.triangle.fill") { ViolationsTab(viewModel: guardVM) }
        }
        .tint(Color.upPrimary)
    }
}

// MARK: - Splash mientras se comprueba sesión
private struct SplashView: View {
    var body: some View {
        ZStack {
            Color.upBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "parkingsign.circle.fill")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(Color.upPrimary)
                Text("UniPark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.upPrimary)
                ProgressView()
                    .tint(Color.upPrimary)
                    .padding(.top, 8)
            }
        }
    }
}
