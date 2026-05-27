import SwiftUI

public struct RootView: View {
    private let devMode: Bool = true
    @State private var devRole: UserRole? = nil
    @State private var isAuthenticated: Bool = false
    @State private var currentUser: User? = nil
    @State private var driverVM = DriverViewModel()
    @State private var guardVM = GuardViewModel()
    @State private var selectedDriverTab: Int = 0

    public init() {}

    public var body: some View {
        Group {
            if devMode {
                if let devRole {
                    switch devRole {
                    case .driver:
                        driverTabs
                    case .securityGuard:
                        guardTabs
                    case .admin:
                        Text("Admin View - Coming Soon")
                    case .superadmin:
                        Text("Superadmin View - Coming Soon")
                    }
                } else {
                    DevRoleSelectorView { selectedRole in
                        devRole = selectedRole
                    }
                }
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
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("signOut"))) { _ in
            signOut()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("navigateToAccessTab"))) { _ in
            selectedDriverTab = 3
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

    private func signOut() {
        if devMode {
            devRole = nil
        } else {
            isAuthenticated = false
            currentUser = nil
        }
    }

    // MARK: - Driver Tabs
    private var driverTabs: some View {
        TabView(selection: $selectedDriverTab) {
            Tab("Inicio", systemImage: "house.fill", value: 0) {
                HomeTab(viewModel: driverVM)
            }
            
            Tab("Mapa", systemImage: "map.fill", value: 1) {
                MapTab(viewModel: driverVM)
            }
            
            Tab("Permiso", systemImage: "qrcode", value: 2) {
                PermitStickerTab(viewModel: driverVM)
            }
            
            Tab("Acceso", systemImage: "qrcode.viewfinder", value: 3) {
                AccessQRTab(viewModel: driverVM)
            }
        }
        .tint(Color.upPrimary)
    }

    // MARK: - Guard Tabs
    private var guardTabs: some View {
        TabView {
            Tab("Scanner", systemImage: "qrcode.viewfinder") {
                ScannerTab(viewModel: guardVM)
            }
            Tab("Lotes", systemImage: "car.2.fill") {
                LotCapacityTab(viewModel: guardVM)
            }
            Tab("Infracciones", systemImage: "exclamationmark.triangle.fill") {
                ViolationsTab(viewModel: guardVM)
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

private struct DevRoleSelectorView: View {
    let onSelect: (UserRole) -> Void

    var body: some View {
        ZStack {
            Color.upBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "parkingsign.circle.fill")
                        .font(.system(size: 54, weight: .semibold))
                        .foregroundStyle(Color.upPrimary)

                    Text("UniPark")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color.upPrimary)

                    Text("Modo Desarrollo — Selecciona tu rol")
                        .font(.subheadline)
                        .foregroundStyle(Color.upTextSecondary)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 24)

                VStack(spacing: 14) {
                    roleCard(
                        title: "Conductor",
                        subtitle: "Ver pase QR, wallet, mapa",
                        systemImage: "car.fill",
                        tint: .upSecondary,
                        action: { onSelect(.driver) }
                    )

                    roleCard(
                        title: "Guardia",
                        subtitle: "Scanner QR, lotes, violaciones",
                        systemImage: "shield.fill",
                        tint: .upPrimary,
                        action: { onSelect(.securityGuard) }
                    )
                }

                Spacer(minLength: 8)

                Text("⚠️ Dev Mode — autenticación deshabilitada")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.upTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    private func roleCard(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.upTextPrimary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.upTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.upTextSecondary)
            }
            .padding(18)
        }
        .buttonStyle(.plain)
        .glassCard(cornerRadius: 20, glowColor: tint)
    }
}
