import Foundation
import Auth0

/// Coordinador de autenticación de la app sobre **Auth0**.
///
/// Mantiene la misma API pública (`login`/`logout`/`currentUser`/`refreshTokenIfNeeded`)
/// para que `LoginView`, `AuthRepositoryImpl` y la capa de red (que lee
/// `TokenStorage.shared.accessToken`) no necesiten cambios.
@MainActor
public final class OIDCAuthManager: NSObject {
    public static let shared = OIDCAuthManager()

    /// Namespace de los custom claims emitidos por el Auth0 Action.
    /// Debe coincidir con `SecurityConfig` del backend.
    private static let ns = "https://unipark.edu.sv"
    private static let emailClaim = "\(ns)/email"
    private static let realmAccessClaim = "\(ns)/realm_access"

    private let authService = AppAuthService()

    private override init() {
        super.init()
    }

    // MARK: - Public API

    public func login() async throws -> User {
        let credentials = try await authService.login()
        TokenStorage.shared.save(
            accessToken: credentials.accessToken,
            refreshToken: credentials.refreshToken ?? "",
            idToken: credentials.idToken
        )

        guard let user = currentUser() else {
            throw NetworkError.decodingError
        }
        return user
    }

    public func logout() async throws {
        // Intenta cerrar la sesión SSO en Auth0; aunque falle, limpia el estado local.
        try? await authService.logout()
        TokenStorage.shared.clear()
    }

    public func refreshTokenIfNeeded() async throws {
        guard let accessToken = TokenStorage.shared.accessToken else {
            throw NetworkError.unauthorized
        }

        if let payload = decodeJWTPayload(accessToken),
           let exp = payload["exp"] as? Double {
            let expiration = Date(timeIntervalSince1970: exp)
            // Margen de 60s para evitar usar un token al borde de expirar.
            if expiration > Date().addingTimeInterval(60) {
                return
            }
        }

        guard let refreshToken = TokenStorage.shared.refreshToken,
              !refreshToken.isEmpty else {
            throw NetworkError.unauthorized
        }

        do {
            let credentials = try await authService.renew(refreshToken: refreshToken)
            TokenStorage.shared.save(
                accessToken: credentials.accessToken,
                refreshToken: credentials.refreshToken ?? refreshToken,
                idToken: credentials.idToken
            )
        } catch {
            throw NetworkError.unauthorized
        }
    }

    public func currentUser() -> User? {
        guard let accessToken = TokenStorage.shared.accessToken,
              let accessClaims = decodeJWTPayload(accessToken) else {
            return nil
        }
        // El ID token trae los claims estándar de perfil (email/given_name/family_name).
        let idClaims = TokenStorage.shared.idToken.flatMap { decodeJWTPayload($0) } ?? [:]

        guard let sub = accessClaims["sub"] as? String else { return nil }

        // Email: claim namespaced del access token (lo emite el Action) → fallback al ID token.
        let email = (accessClaims[Self.emailClaim] as? String)
            ?? (idClaims["email"] as? String)
            ?? (accessClaims["email"] as? String)

        guard let email else { return nil }

        let givenName  = (idClaims["given_name"]  as? String) ?? ""
        let familyName = (idClaims["family_name"] as? String) ?? ""
        let nameClaim  = (idClaims["name"] as? String) ?? ""
        let fullName   = [givenName, familyName].filter { !$0.isEmpty }.joined(separator: " ")
        let displayName = !fullName.isEmpty ? fullName : (!nameClaim.isEmpty ? nameClaim : email)

        // Roles: Auth0 Action los emite namespaced en {ns}/realm_access.roles.
        // Se mantienen fallbacks a realm_access plano y a `role` por compatibilidad.
        func parseRole(_ raw: String) -> UserRole? {
            switch raw.lowercased() {
            case "guard", "securityguard", "security_guard": return .securityGuard
            case "driver":      return .driver
            case "admin":       return .admin
            case "superadmin":  return .superadmin
            default:            return nil
            }
        }

        let role: UserRole
        let realmAccess = (accessClaims[Self.realmAccessClaim] as? [String: Any])
            ?? (accessClaims["realm_access"] as? [String: Any])
        if let roles = realmAccess?["roles"] as? [String] {
            role = roles.compactMap { parseRole($0) }.first ?? .driver
        } else if let flatRole = accessClaims["role"] as? String {
            role = parseRole(flatRole) ?? .driver
        } else if let flatRoles = accessClaims["role"] as? [String] {
            role = flatRoles.compactMap { parseRole($0) }.first ?? .driver
        } else {
            role = .driver
        }

        return User(
            id: UUID(uuidString: sub) ?? UUID(),
            email: email,
            fullName: displayName,
            role: role,
            universityId: sub,
            active: true
        )
    }

    // MARK: - JWT Helpers

    private func decodeJWTPayload(_ token: String) -> [String: Any]? {
        let segments = token.split(separator: ".")
        guard segments.count >= 2 else { return nil }

        var payload = String(segments[1])
        let remainder = payload.count % 4
        if remainder != 0 {
            payload += String(repeating: "=", count: 4 - remainder)
        }

        payload = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        guard let data = Data(base64Encoded: payload),
              let object = try? JSONSerialization.jsonObject(with: data, options: []),
              let dict = object as? [String: Any] else {
            return nil
        }

        return dict
    }
}

public extension Notification.Name {
    static let oidcAuthStateDidChange = Notification.Name("oidcAuthStateDidChange")
}
