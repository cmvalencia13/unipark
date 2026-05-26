import Foundation

// TODO: implemented in data/repositories/
public protocol AuthRepository {
	func login() async throws -> User
	func logout() async throws
	func currentUser() async throws -> User?
	func refreshToken() async throws
}