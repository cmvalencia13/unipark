import Foundation
import Auth0

/// Configuración y wrapper de autenticación con **Auth0**.
///
/// Reemplaza la implementación manual de PKCE / ASWebAuthenticationSession contra
/// Keycloak. Auth0.swift maneja PKCE, el navegador seguro y el callback internamente.
///
/// ── Valores a completar por el responsable de Auth0 ──────────────────────────
/// `domain`   → el dominio del tenant, p.ej. "unipark.us.auth0.com" (SIN https://).
/// `clientID` → Client ID de la app **Native** "UniPark iOS" en el dashboard Auth0.
/// `audience` → el Identifier de la API en Auth0 ("https://api.unipark.edu.sv").
///              OBLIGATORIO: sin audience el access token es opaco y el backend lo rechaza.
///
/// El callback que debes registrar en Auth0 (Allowed Callback URLs / Logout URLs) es:
///   {bundleId}://{domain}/ios/{bundleId}/callback
///   p.ej. com.unipark.app://unipark.us.auth0.com/ios/com.unipark.app/callback
/// Auth0.swift lo genera automáticamente; basta con whitelistarlo en el dashboard.
public struct AppAuthService {

    // TODO(Auth0): reemplazar por los valores reales del tenant antes de probar.
    public static let domain   = "TU_DOMINIO.us.auth0.com"
    public static let clientID = "TU_CLIENT_ID_IOS"
    public static let audience = "https://api.unipark.edu.sv"
    public static let scope    = "openid profile email offline_access"

    public init() {}

    /// Lanza el flujo de login universal de Auth0 y devuelve las credenciales.
    public func login() async throws -> Credentials {
        try await Auth0
            .webAuth(clientId: Self.clientID, domain: Self.domain)
            .audience(Self.audience)
            .scope(Self.scope)
            .start()
    }

    /// Cierra la sesión del navegador en Auth0 (borra la cookie SSO del tenant).
    public func logout() async throws {
        try await Auth0
            .webAuth(clientId: Self.clientID, domain: Self.domain)
            .clearSession()
    }

    /// Renueva el access token usando el refresh token (requiere scope offline_access).
    public func renew(refreshToken: String) async throws -> Credentials {
        try await Auth0
            .authentication(clientId: Self.clientID, domain: Self.domain)
            .renew(withRefreshToken: refreshToken)
            .start()
    }
}
