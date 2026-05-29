import Foundation
import AuthenticationServices
import UIKit

@MainActor
public final class OIDCAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
	public static let shared = OIDCAuthManager()
	private let devMode: Bool = FeatureFlags.devMode

    public static let clientID   = AppAuthService.clientID
    public static let redirectURI = AppAuthService.redirectURI

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
		print("[OIDCAuth] callback: \(callbackURL.absoluteString.prefix(200))")
		if let state = queryItems.first(where: { $0.name == "state" })?.value {
			print("[OIDCAuth] state match=\(state == expectedState)")
			if state != expectedState {
				throw NSError(domain: "OIDCAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "State mismatch: got \(state)"])
			}
		}

		if let error = queryItems.first(where: { $0.name == "error" })?.value {
			throw NSError(domain: "OIDCAuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
		}

		guard let code = queryItems.first(where: { $0.name == "code" })?.value else {
			throw NSError(domain: "OIDCAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No code in callback"])
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
			if expiration > Date() { return }
		}

		guard let storedRefresh = TokenStorage.shared.refreshToken, !storedRefresh.isEmpty else {
			throw NetworkError.unauthorized
		}

		let tokens = try await authService.refreshToken(storedRefresh)
		TokenStorage.shared.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
	}

    public func currentUser() -> User? {
        guard let accessToken = TokenStorage.shared.accessToken,
              let claims = decodeJWTPayload(accessToken) else {
            return nil
        }

        guard let sub   = claims["sub"] as? String,
              let email = claims["email"] as? String else {
            return nil
        }

        let givenName  = claims["given_name"]  as? String ?? ""
        let familyName = claims["family_name"] as? String ?? ""
        let fullName   = [givenName, familyName].filter { !$0.isEmpty }.joined(separator: " ")

        // Keycloak pone los roles en realm_access.roles (array).
        // "guard" en Keycloak → .securityGuard en la app (el rawValue del enum es "securityGuard")
        let role: UserRole
        func parseRole(_ raw: String) -> UserRole? {
            switch raw.lowercased() {
            case "guard", "securityguard", "security_guard": return .securityGuard
            case "driver":      return .driver
            case "admin":       return .admin
            case "superadmin":  return .superadmin
            default:            return nil
            }
        }
        if let realmAccess = claims["realm_access"] as? [String: Any],
           let roles = realmAccess["roles"] as? [String] {
            role = roles.compactMap { parseRole($0) }.first ?? .driver
        } else if let flatRole = claims["role"] as? String {
            role = parseRole(flatRole) ?? .driver
        } else if let flatRoles = claims["role"] as? [String] {
            role = flatRoles.compactMap { parseRole($0) }.first ?? .driver
        } else {
            role = .driver
        }

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

	@available(iOS, deprecated: 26.0)
	public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
	}
}


public extension Notification.Name {
	static let oidcAuthStateDidChange = Notification.Name("oidcAuthStateDidChange")
}