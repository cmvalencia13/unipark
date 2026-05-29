import SwiftUI

public struct LoginView: View {
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 72, weight: .semibold))
                        .foregroundStyle(.blue)

                    Text("UniPark")
                        .font(.largeTitle.bold())

                    Text("Universidad • Movilidad • Acceso seguro")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                Button {
                    Task { await login() }
                } label: {
                    HStack(spacing: 12) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "person.badge.key.fill")
                        }
                        Text("Iniciar sesión con cuenta universitaria")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(isLoading)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Acceso")
            .navigationBarTitleDisplayMode(.inline)
            .alert("No se pudo iniciar sesión", isPresented: $showErrorAlert) {
                Button("OK") { errorMessage = nil }
            } message: {
                if let errorMessage {
                    Text(errorMessage)
                }
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
