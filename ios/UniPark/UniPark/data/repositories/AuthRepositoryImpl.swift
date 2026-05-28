import Foundation

public final class AuthRepositoryImpl: AuthRepository {
	public init() {}

	public func login() async throws -> User {
		try await OIDCAuthManager.shared.login()
	}

	public func logout() async throws {
		try await OIDCAuthManager.shared.logout()
	}

	public func currentUser() async throws -> User? {
		OIDCAuthManager.shared.currentUser()
	}

	public func refreshToken() async throws {
		try await OIDCAuthManager.shared.refreshTokenIfNeeded()
	}
}