import Foundation
import CryptoKit
import Security

public struct AppAuthService {
    // Dev local  → http://localhost:8080/realms/unipark  (simulador iOS accede a localhost directamente)
    // Producción → https://auth.universidad.edu.sv/realms/unipark
    public static let issuerURL = "http://localhost:8080/realms/unipark"
    public static let clientID = "unipark-ios"
    public static let redirectURI = "com.unipark.app://callback"

	// PKCE material generated when building the auth URL.
	static var pendingCodeVerifier: String?
	static var pendingState: String?
	static var pendingNonce: String?

	public init() {}

	public func buildAuthURL() -> URL {
		let verifier = generateCodeVerifier()
		let challenge = generateCodeChallenge(from: verifier)
		let state = randomURLSafeString(byteCount: 16)
		let nonce = randomURLSafeString(byteCount: 16)

		Self.pendingCodeVerifier = verifier
		Self.pendingState = state
		Self.pendingNonce = nonce

		let authEndpoint = "\(Self.issuerURL)/protocol/openid-connect/auth"
		var components = URLComponents(string: authEndpoint)!
		components.queryItems = [
			URLQueryItem(name: "response_type", value: "code"),
			URLQueryItem(name: "client_id", value: Self.clientID),
			URLQueryItem(name: "redirect_uri", value: Self.redirectURI),
			URLQueryItem(name: "scope", value: "openid profile email offline_access"),
			URLQueryItem(name: "state", value: state),
			URLQueryItem(name: "nonce", value: nonce),
			URLQueryItem(name: "code_challenge", value: challenge),
			URLQueryItem(name: "code_challenge_method", value: "S256")
		]

		return components.url!
	}

	public func exchangeCode(_ code: String, codeVerifier: String) async throws -> (accessToken: String, refreshToken: String) {
		let tokenEndpoint = URL(string: "\(Self.issuerURL)/protocol/openid-connect/token")!
		var request = URLRequest(url: tokenEndpoint)
		request.httpMethod = "POST"
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")

		let bodyItems: [URLQueryItem] = [
			URLQueryItem(name: "grant_type", value: "authorization_code"),
			URLQueryItem(name: "client_id", value: Self.clientID),
			URLQueryItem(name: "code", value: code),
			URLQueryItem(name: "redirect_uri", value: Self.redirectURI),
			URLQueryItem(name: "code_verifier", value: codeVerifier)
		]
		request.httpBody = bodyItems
			.map { "\($0.name)=\(($0.value ?? "").urlEncoded())" }
			.joined(separator: "&")
			.data(using: .utf8)

		let (data, response) = try await URLSession.shared.data(for: request)
		guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
			throw NetworkError.unauthorized
		}

		let payload = try JSONDecoder().decode(TokenExchangeResponse.self, from: data)
		return (accessToken: payload.accessToken, refreshToken: payload.refreshToken)
	}

	public func generateCodeVerifier() -> String {
		// 32 bytes => 43 chars base64url, within PKCE requirements.
		randomURLSafeString(byteCount: 32)
	}

	public func generateCodeChallenge(from verifier: String) -> String {
		let digest = SHA256.hash(data: Data(verifier.utf8))
		return Data(digest).base64URLEncodedString()
	}

	// MARK: - Private helpers

	private func randomURLSafeString(byteCount: Int) -> String {
		var bytes = [UInt8](repeating: 0, count: byteCount)
		let result = SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes)
		precondition(result == errSecSuccess, "Unable to generate secure random bytes")
		return Data(bytes).base64URLEncodedString()
	}
}

private struct TokenExchangeResponse: Decodable {
	let accessToken: String
	let refreshToken: String

	private enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case refreshToken = "refresh_token"
	}
}

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