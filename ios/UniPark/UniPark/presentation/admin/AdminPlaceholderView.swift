import SwiftUI

public struct AdminPlaceholderView: View {
    public init() {}

    public var body: some View {
        ZStack {
            Color.upBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(Color.upPrimary)
                    .neonGlow(color: .upPrimary, radius: 20)

                Text("Panel de Administración")
                    .font(.title.bold())
                    .foregroundStyle(Color.upTextPrimary)

                Text("Esta sección está en desarrollo.\nEstarán disponibles: reportes de ocupación,\ngestión de usuarios y configuración de lotes.")
                    .font(.body)
                    .foregroundStyle(Color.upTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(spacing: 0) {
                    Label("Reportes de ocupación", systemImage: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(Color.upTextSecondary)
                        .padding(.vertical, 8)
                    Label("Gestión de usuarios", systemImage: "person.2.fill")
                        .foregroundStyle(Color.upTextSecondary)
                        .padding(.vertical, 8)
                    Label("Configuración de lotes", systemImage: "mappin.and.ellipse")
                        .foregroundStyle(Color.upTextSecondary)
                        .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .glassCard(cornerRadius: 16, glowColor: .upPrimary)

                Button(action: {
                    NotificationCenter.default.post(name: Notification.Name("signOut"), object: nil)
                }) {
                    Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.upTextSecondary)
                }
                .buttonStyle(.plain)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        }
    }
}
