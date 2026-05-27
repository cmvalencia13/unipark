import Foundation
import AuthenticationServices
import UIKit

@MainActor
public final class OIDCAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
	public static let shared = OIDCAuthManager()
	private let devMode: Bool = FeatureFlags.devMode

	public static let issuerURL = "https://auth.universidad.edu/realms/unipark"
	public static let clientID = "unipark-ios"
	public static let redirectURI = "com.unipark.app://callback"

	private let authService = AppAuthService()
	private var authSession: ASWebAuthenticationSession?

	private override init() {
		super.init()
	}

	// MARK: - Public API

	public func login() async throws -> User {
		let authURL = authService.buildAuthURL()
		guard let codeVerifier = AppAuthService.pendingCodeVerifier,
			  let expectedState = AppAuthService.pendingState else {
			throw NetworkError.decodingError
		}

		let callbackURL = try await startWebAuthSession(authURL: authURL)

		let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)
		let queryItems = components?.queryItems ?? []
		if let state = queryItems.first(where: { $0.name == "state" })?.value, state != expectedState {
			throw NetworkError.unauthorized
		}

		if let error = queryItems.first(where: { $0.name == "error" })?.value {
			throw NSError(domain: "OIDCAuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
		}

		guard let code = queryItems.first(where: { $0.name == "code" })?.value else {
			throw NetworkError.unauthorized
		}

		let tokens = try await authService.exchangeCode(code, codeVerifier: codeVerifier)
		TokenStorage.shared.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)

		guard let user = currentUser() else {
			throw NetworkError.decodingError
		}

		return user
	}

	public func logout() async throws {
		authSession?.cancel()
		authSession = nil
		TokenStorage.shared.clear()
	}

	public func refreshTokenIfNeeded() async throws {
		guard let accessToken = TokenStorage.shared.accessToken else { throw NetworkError.unauthorized }

		if let payload = decodeJWTPayload(accessToken),
		   let exp = payload["exp"] as? Double {
			let expiration = Date(timeIntervalSince1970: exp)
			if expiration > Date() {
				return
			}
		}

		guard let refreshToken = TokenStorage.shared.refreshToken else {
			throw NetworkError.unauthorized
		}

		let tokenEndpoint = URL(string: "\(Self.issuerURL)/protocol/openid-connect/token")!
		var request = URLRequest(url: tokenEndpoint)
		request.httpMethod = "POST"
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		let body = [
			"grant_type": "refresh_token",
			"client_id": Self.clientID,
			"refresh_token": refreshToken
		]
		request.httpBody = body
			.map { "\($0.key)=\($0.value.urlEncoded())" }
			.joined(separator: "&")
			.data(using: .utf8)

		let (data, response) = try await URLSession.shared.data(for: request)
		guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
			throw NetworkError.unauthorized
		}

		let refreshed = try JSONDecoder().decode(RefreshResponse.self, from: data)
		TokenStorage.shared.save(accessToken: refreshed.accessToken, refreshToken: refreshed.refreshToken)
	}

	public func currentUser() -> User? {
		if devMode {
			return User(
				email: "test@universidad.edu",
				fullName: "Carlos Test",
				role: .driver,
				universityId: "DEV-000",
				active: true
			)
		}

		guard let accessToken = TokenStorage.shared.accessToken,
			  let claims = decodeJWTPayload(accessToken) else {
			return nil
		}

		guard let sub = claims["sub"] as? String,
			  let email = claims["email"] as? String else {
			return nil
		}

		let givenName = claims["given_name"] as? String ?? ""
		let familyName = claims["family_name"] as? String ?? ""
		let fullName = [givenName, familyName].filter { !$0.isEmpty }.joined(separator: " ")
		let roleString = (claims["role"] as? String ?? "driver").lowercased()
		let role = UserRole(rawValue: roleString) ?? .driver

		return User(
			id: UUID(uuidString: sub) ?? UUID(),
			email: email,
			fullName: fullName.isEmpty ? email : fullName,
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

	// MARK: - Session

	private func startWebAuthSession(authURL: URL) async throws -> URL {
		try await withCheckedThrowingContinuation { continuation in
			let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: URL(string: Self.redirectURI)?.scheme) { [weak self] callbackURL, error in
				DispatchQueue.main.async {
					defer { self?.authSession = nil }

					if let error = error {
						continuation.resume(throwing: error)
						return
					}

					guard let callbackURL else {
						continuation.resume(throwing: NetworkError.unauthorized)
						return
					}

					continuation.resume(returning: callbackURL)
				}
			}

			session.presentationContextProvider = self
			session.prefersEphemeralWebBrowserSession = true
			self.authSession = session

			if !session.start() {
				self.authSession = nil
				continuation.resume(throwing: NetworkError.noConnection)
			}
		}
	}

	// MARK: - Presentation

	public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
	}
}

private struct RefreshResponse: Decodable {
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

public extension Notification.Name {
	static let oidcAuthStateDidChange = Notification.Name("oidcAuthStateDidChange")
}