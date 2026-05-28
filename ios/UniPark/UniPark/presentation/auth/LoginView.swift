import SwiftUI

public struct LoginView: View {
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false

    public init() {}

    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#0A1628"), Color(hex: "#0D2137"), Color(hex: "#0A2E1F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header logo section
                    VStack(spacing: 16) {
                        Spacer().frame(height: 60)

                        ZStack {
                            Circle()
                                .fill(Color.upPrimary.opacity(0.15))
                                .frame(width: 100, height: 100)
                            Circle()
                                .fill(Color.upPrimary.opacity(0.08))
                                .frame(width: 130, height: 130)
                            Image(systemName: "parkingsign.circle.fill")
                                .font(.system(size: 52, weight: .semibold))
                                .foregroundStyle(Color.upPrimary)
                        }

                        Text("UniPark")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Sistema de Gestión de Parqueos")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)

                    Spacer().frame(height: 48)

                    // Login card
                    VStack(spacing: 0) {
                        VStack(spacing: 20) {
                            VStack(spacing: 6) {
                                Text("Iniciar Sesión")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Usa tu cuenta universitaria institucional")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Divider()
                                .background(.white.opacity(0.1))

                            // SSO Button
                            Button {
                                Task { await login() }
                            } label: {
                                HStack(spacing: 12) {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.black)
                                            .scaleEffect(0.85)
                                    } else {
                                        Image(systemName: "person.badge.key.fill")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    Text(isLoading ? "Autenticando…" : "Continuar con SSO Universitario")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .foregroundStyle(.black)
                                .background(Color.upPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .disabled(isLoading)

                            // Info pills
                            HStack(spacing: 8) {
                                InfoPill(icon: "shield.fill", label: "Keycloak OIDC")
                                InfoPill(icon: "lock.fill", label: "PKCE Seguro")
                                InfoPill(icon: "person.2.fill", label: "Roles")
                            }
                        }
                        .padding(24)
                    }
                    .background(.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 32)

                    // Role info cards
                    VStack(spacing: 10) {
                        Text("Accesos disponibles")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)

                        HStack(spacing: 10) {
                            RoleCard(icon: "car.fill", role: "Conductor", color: Color.upPrimary)
                            RoleCard(icon: "shield.lefthalf.filled", role: "Guardia", color: .orange)
                            RoleCard(icon: "gearshape.2.fill", role: "Admin", color: .purple)
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer().frame(height: 40)

                    Text("© 2025 UniPark · Universidad de El Salvador")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.25))

                    Spacer().frame(height: 24)
                }
            }
        }
        .alert("No se pudo iniciar sesión", isPresented: $showErrorAlert) {
            Button("OK") { errorMessage = nil }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }

    private func login() async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        defer { Task { @MainActor in isLoading = false } }

        do {
            let user = try await OIDCAuthManager.shared.login()
            NotificationCenter.default.post(name: .oidcAuthStateDidChange, object: nil, userInfo: ["user": user])
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}

// MARK: - Sub-components

private struct InfoPill: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(.white.opacity(0.7))
        .background(.white.opacity(0.06))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.1), lineWidth: 1))
    }
}

private struct RoleCard: View {
    let icon: String
    let role: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(color)
            }
            Text(role)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(color.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Hex Color helper (if not already defined globally)
private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
