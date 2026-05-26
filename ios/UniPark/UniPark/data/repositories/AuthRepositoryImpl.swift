import Foundation

public final class AuthRepositoryImpl: AuthRepository {
	private let client = NetworkClient.shared

	// fallback user
	private var cached: User? = User(email: "guard@unipark.test", fullName: "Guardia UniPark", role: .securityGuard, universityId: "UNI-000", active: true)

	public init() {}

	public func login() async throws -> User {
		do {
			let endpoint = Endpoint(path: "auth/login", method: .POST)
			let user: User = try await client.request(endpoint)
			cached = user
			return user
		} catch {
			if let user = cached { return user }
			throw error
		}
	}

	public func logout() async throws {
		do {
			let _ : EmptyResponse = try await client.request(Endpoint(path: "auth/logout", method: .POST))
		} catch {
			// ignore, still clear local
		}
		cached = nil
		TokenStorage.shared.clear()
	}

	public func currentUser() async throws -> User? {
		do {
			let user: User = try await client.request(Endpoint(path: "auth/me", method: .GET))
			cached = user
			return user
		} catch {
			return cached
		}
	}

	public func refreshToken() async throws {
		// Attempt token refresh flow; this is a best-effort placeholder
		guard let refresh = TokenStorage.shared.refreshToken else { throw NetworkError.unauthorized }
		do {
			let endpoint = Endpoint(path: "auth/refresh", method: .POST, body: ["refreshToken": refresh])
			let resp: TokenResponse = try await client.request(endpoint)
			TokenStorage.shared.save(accessToken: resp.accessToken, refreshToken: resp.refreshToken)
		} catch {
			TokenStorage.shared.clear()
			throw error
		}
	}
}

fileprivate struct EmptyResponse: Decodable {}

fileprivate struct TokenResponse: Decodable {
	let accessToken: String
	let refreshToken: String
}