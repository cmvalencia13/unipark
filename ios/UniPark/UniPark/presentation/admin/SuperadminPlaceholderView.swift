import SwiftUI

public struct SuperadminPlaceholderView: View {
    public init() {}

    public var body: some View {
        ZStack {
            Color.upBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(Color.upPrimary)
                    .neonGlow(color: .upPrimary, radius: 20)

                Text("Panel Superadmin")
                    .font(.title.bold())
                    .foregroundStyle(Color.upTextPrimary)

                Text("Acceso total al sistema en desarrollo.\nEstarán disponibles: gestión de administradores,\naudit log y configuración global.")
                    .font(.body)
                    .foregroundStyle(Color.upTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(spacing: 0) {
                    Label("Gestión de administradores", systemImage: "person.badge.key.fill")
                        .foregroundStyle(Color.upTextSecondary)
                        .padding(.vertical, 8)
                    Label("Audit log del sistema", systemImage: "list.bullet.clipboard.fill")
                        .foregroundStyle(Color.upTextSecondary)
                        .padding(.vertical, 8)
                    Label("Configuración global", systemImage: "gearshape.2.fill")
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
