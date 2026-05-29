import SwiftUI

// MARK: - Models

struct AdminStats: Decodable {
    let lots: [LotOccupancy]
    let todayScans: Int
    let pendingViolations: Int
    let totalUsers: Int
}

struct LotOccupancy: Decodable, Identifiable {
    var id: String { name }
    let name: String
    let capacityTotal: Int
    let capacityUsed: Int
    var occupancyPercent: Double {
        guard capacityTotal > 0 else { return 0 }
        return Double(capacityUsed) / Double(capacityTotal)
    }
}

struct UserSummary: Decodable, Identifiable {
    let id: String
    let email: String
    let fullName: String
    let role: String
    let universityId: String
    let active: Bool
}

struct AdminPageResponse: Decodable {
    let content: [UserSummary]
    let totalElements: Int
    let totalPages: Int
}

// MARK: - API Client

@MainActor
final class AdminAPIClient {
    static let shared = AdminAPIClient()
    private let base = URL(string: FeatureFlags.backendBaseURL)!

    func fetchStats() async throws -> AdminStats {
        var req = URLRequest(url: base.appendingPathComponent("admin/stats"))
        req.setValue("Bearer \(TokenStorage.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(AdminStats.self, from: data)
    }

    func fetchUsers(page: Int = 0) async throws -> AdminPageResponse {
        var url = base.appendingPathComponent("admin/users")
        url.append(queryItems: [.init(name: "page", value: "\(page)"), .init(name: "size", value: "20")])
        var req = URLRequest(url: url)
        req.setValue("Bearer \(TokenStorage.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(AdminPageResponse.self, from: data)
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class AdminViewModel {
    var stats: AdminStats? = nil
    var users: [UserSummary] = []
    var totalUsers: Int = 0
    var isLoading: Bool = false
    var errorMessage: String? = nil

    func refresh() async {
        isLoading = true
        errorMessage = nil
        async let statsTask = AdminAPIClient.shared.fetchStats()
        async let usersTask = AdminAPIClient.shared.fetchUsers()
        do {
            let (s, u) = try await (statsTask, usersTask)
            stats = s
            users = u.content
            totalUsers = u.totalElements
        } catch {
            errorMessage = "Error cargando datos: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

// MARK: - Main View

public struct AdminDashboardView: View {
    @State private var vm = AdminViewModel()
    @State private var selectedTab: Int = 0

    public init() {}

    public var body: some View {
        ZStack {
            Color.upBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.upPrimary)
                        Text("UniPark Admin")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.upTextPrimary)
                    }
                    Spacer()
                    Button {
                        NotificationCenter.default.post(name: Notification.Name("signOut"), object: nil)
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(Color.upTextSecondary)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(Color.upSurface)

                // Tab selector
                HStack(spacing: 0) {
                    tabButton("Resumen", icon: "chart.bar.fill", tag: 0)
                    tabButton("Lotes", icon: "car.2.fill", tag: 1)
                    tabButton("Usuarios", icon: "person.2.fill", tag: 2)
                }
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(Color.upSurface)

                Divider()

                if vm.isLoading && vm.stats == nil {
                    Spacer()
                    ProgressView().tint(Color.upPrimary)
                    Spacer()
                } else if let error = vm.errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle").font(.system(size: 36)).foregroundStyle(Color.upError)
                        Text(error).font(.caption).foregroundStyle(Color.upTextSecondary).multilineTextAlignment(.center)
                        Button("Reintentar") { Task { await vm.refresh() } }
                            .foregroundStyle(Color.upPrimary)
                    }.padding(32)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        switch selectedTab {
                        case 0: summaryTab
                        case 1: lotsTab
                        case 2: usersTab
                        default: EmptyView()
                        }
                    }
                    .refreshable { await vm.refresh() }
                }
            }
        }
        .task { await vm.refresh() }
    }

    // MARK: - Summary Tab

    private var summaryTab: some View {
        VStack(spacing: 16) {
            // KPI grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                KPICard(value: "\(vm.stats?.todayScans ?? 0)", label: "Escaneos hoy", icon: "qrcode.viewfinder", color: .upPrimary)
                KPICard(value: "\(vm.stats?.pendingViolations ?? 0)", label: "Infracciones pendientes", icon: "exclamationmark.triangle.fill", color: .upError)
                KPICard(value: "\(vm.stats?.totalUsers ?? 0)", label: "Usuarios registrados", icon: "person.2.fill", color: .upSecondary)
                KPICard(
                    value: "\(vm.stats?.lots.reduce(0) { $0 + $1.capacityUsed } ?? 0)",
                    label: "Vehículos dentro",
                    icon: "car.fill",
                    color: Color.orange
                )
            }

            // Lots summary
            if let lots = vm.stats?.lots, !lots.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("OCUPACIÓN EN TIEMPO REAL")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.upPrimary)
                        .kerning(1.2)

                    ForEach(lots) { lot in
                        LotOccupancyRow(lot: lot)
                    }
                }
                .padding(16)
                .background(Color.upSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
    }

    // MARK: - Lots Tab

    private var lotsTab: some View {
        VStack(spacing: 12) {
            ForEach(vm.stats?.lots ?? []) { lot in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(lot.name).font(.headline.weight(.bold)).foregroundStyle(Color.upTextPrimary)
                        Spacer()
                        occupancyBadge(lot: lot)
                    }

                    ProgressView(value: lot.occupancyPercent)
                        .tint(occupancyColor(lot.occupancyPercent))

                    HStack {
                        Label("\(lot.capacityUsed) ocupados", systemImage: "car.fill")
                            .font(.caption).foregroundStyle(Color.upTextSecondary)
                        Spacer()
                        Label("\(lot.capacityTotal - lot.capacityUsed) libres", systemImage: "parkingsign.circle")
                            .font(.caption).foregroundStyle(Color.upTextSecondary)
                    }
                }
                .padding(16)
                .background(Color.upSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
    }

    // MARK: - Users Tab

    private var usersTab: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(vm.totalUsers) usuarios totales")
                    .font(.caption).foregroundStyle(Color.upTextSecondary)
                Spacer()
            }
            .padding(.horizontal, 4)

            ForEach(vm.users) { user in
                HStack(spacing: 12) {
                    Circle()
                        .fill(roleColor(user.role))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text(user.fullName.prefix(1))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.fullName).font(.subheadline.weight(.semibold)).foregroundStyle(Color.upTextPrimary)
                        Text(user.email).font(.caption).foregroundStyle(Color.upTextSecondary)
                    }

                    Spacer()

                    Text(user.role.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(roleColor(user.role))
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(roleColor(user.role).opacity(0.15))
                        .clipShape(Capsule())
                }
                .padding(12)
                .background(Color.upSurface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
    }

    // MARK: - Helpers

    private func tabButton(_ title: String, icon: String, tag: Int) -> some View {
        Button {
            selectedTab = tag
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 16))
                Text(title).font(.caption2.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundStyle(selectedTab == tag ? Color.upPrimary : Color.upTextSecondary)
            .background(selectedTab == tag ? Color.upPrimary.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func occupancyBadge(lot: LotOccupancy) -> some View {
        let pct = Int(lot.occupancyPercent * 100)
        let color = occupancyColor(lot.occupancyPercent)
        return Text("\(pct)%")
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }

    private func occupancyColor(_ pct: Double) -> Color {
        if pct >= 0.9 { return .upError }
        if pct >= 0.7 { return .orange }
        return .upSecondary
    }

    private func roleColor(_ role: String) -> Color {
        switch role.lowercased() {
        case "driver":      return .upSecondary
        case "guard":       return .upPrimary
        case "admin":       return .purple
        case "superadmin":  return .upError
        default:            return .gray
        }
    }
}

// MARK: - Sub-views

private struct KPICard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.system(size: 20)).foregroundStyle(color)
            Text(value).font(.system(size: 28, weight: .bold)).foregroundStyle(Color.upTextPrimary)
            Text(label).font(.caption).foregroundStyle(Color.upTextSecondary).lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.upSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct LotOccupancyRow: View {
    let lot: LotOccupancy

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(lot.name).font(.subheadline.weight(.semibold)).foregroundStyle(Color.upTextPrimary)
                Spacer()
                Text("\(lot.capacityUsed)/\(lot.capacityTotal)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(barColor)
            }
            ProgressView(value: lot.occupancyPercent).tint(barColor)
        }
    }

    private var barColor: Color {
        if lot.occupancyPercent >= 0.9 { return .upError }
        if lot.occupancyPercent >= 0.7 { return .orange }
        return .upSecondary
    }
}
