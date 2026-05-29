import Foundation
import CryptoKit
import Security

/// Configuración de Auth0 para UniPark.
/// El archivo Auth0.plist debe estar en el target con ClientId y Domain.
/// Callback URL registrada en Auth0 Dashboard:
///   com.unipark.app://dev-5ndrp8gm0rm3r0mw.us.auth0.com/ios/com.unipark.app/callback
public struct AppAuthService {

    // MARK: - Auth0 Config
    public static let domain    = "dev-5ndrp8gm0rm3r0mw.us.auth0.com"
    public static let clientID  = "mEzhjEcOibjtfwUoxKRRlykEebqlgYHT"
    public static let audience  = "https://api.unipark.edu.sv"
    public static let scheme    = "com.unipark.app"

    // Callback URL que Auth0 redirige de vuelta a la app
    // Formato SDK: {scheme}://{domain}/ios/{bundle-id}/callback
    public static let redirectURI = "\(scheme)://\(domain)/ios/\(scheme)/callback"

    // Endpoints construidos desde el domain
    public static var authEndpoint: String {
        "https://\(domain)/authorize"
    }
    public static var tokenEndpoint: String {
        "https://\(domain)/oauth/token"
    }
    public static var logoutEndpoint: String {
        "https://\(domain)/v2/logout"
    }

    // MARK: - PKCE state (generado al construir la URL de auth)
    static var pendingCodeVerifier: String?
    static var pendingState: String?

    public init() {}

    // MARK: - Build Auth URL

    public func buildAuthURL() -> URL {
        let verifier  = generateCodeVerifier()
        let challenge = generateCodeChallenge(from: verifier)
        let state     = randomURLSafeString(byteCount: 16)

        Self.pendingCodeVerifier = verifier
        Self.pendingState        = state

        var components = URLComponents(string: Self.authEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "response_type",         value: "code"),
            URLQueryItem(name: "client_id",             value: Self.clientID),
            URLQueryItem(name: "redirect_uri",          value: Self.redirectURI),
            URLQueryItem(name: "scope",                 value: "openid profile email offline_access"),
            URLQueryItem(name: "audience",              value: Self.audience),
            URLQueryItem(name: "state",                 value: state),
            URLQueryItem(name: "code_challenge",        value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
        ]
        return components.url!
    }

    // MARK: - Exchange code for tokens

    public func exchangeCode(_ code: String, codeVerifier: String) async throws -> (accessToken: String, refreshToken: String, idToken: String?) {
        let request = try buildTokenRequest(
            body: [
                "grant_type":    "authorization_code",
                "client_id":     Self.clientID,
                "code":          code,
                "redirect_uri":  Self.redirectURI,
                "code_verifier": codeVerifier,
            ]
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let body = String(data: data, encoding: .utf8) ?? ""
        print("[Auth0] exchangeCode status=\(statusCode)")

        guard (200...299).contains(statusCode) else {
            throw NSError(domain: "Auth0", code: statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Token exchange failed (\(statusCode)): \(body)"])
        }

        let payload = try JSONDecoder().decode(TokenResponse.self, from: data)
        return (payload.accessToken, payload.refreshToken ?? "", payload.idToken)
    }

    // MARK: - Refresh token

    public func refreshToken(_ refreshToken: String) async throws -> (accessToken: String, refreshToken: String) {
        let request = try buildTokenRequest(
            body: [
                "grant_type":    "refresh_token",
                "client_id":     Self.clientID,
                "refresh_token": refreshToken,
            ]
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

        guard (200...299).contains(statusCode) else {
            throw NetworkError.unauthorized
        }

        let payload = try JSONDecoder().decode(TokenResponse.self, from: data)
        return (payload.accessToken, payload.refreshToken ?? refreshToken)
    }

    // MARK: - PKCE helpers

    public func generateCodeVerifier() -> String {
        randomURLSafeString(byteCount: 32)
    }

    public func generateCodeChallenge(from verifier: String) -> String {
        let digest = SHA256.hash(data: Data(verifier.utf8))
        return Data(digest).base64URLEncodedString()
    }

    // MARK: - Private

    private func buildTokenRequest(body: [String: String]) throws -> URLRequest {
        var request = URLRequest(url: URL(string: Self.tokenEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body
            .map { "\($0.key)=\($0.value.urlEncoded())" }
            .joined(separator: "&")
            .data(using: .utf8)
        return request
    }

    private func randomURLSafeString(byteCount: Int) -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        let result = SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes)
        precondition(result == errSecSuccess, "Unable to generate secure random bytes")
        return Data(bytes).base64URLEncodedString()
    }
}

// MARK: - Decodable response

private struct TokenResponse: Decodable {
    let accessToken:  String
    let refreshToken: String?
    let idToken:      String?
    private enum CodingKeys: String, CodingKey {
        case accessToken  = "access_token"
        case refreshToken = "refresh_token"
        case idToken      = "id_token"
    }
}

// MARK: - String helpers

private extension String {
    func urlEncoded() -> String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .replacingOccurrences(of: "+", with: "%2B")
            .replacingOccurrences(of: "&", with: "%26")
            .replacingOccurrences(of: "=", with: "%3D") ?? self
    }
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
