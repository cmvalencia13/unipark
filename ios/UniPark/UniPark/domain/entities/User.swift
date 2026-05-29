import Foundation

public struct User: Identifiable, Codable, Sendable {
	public let id: UUID
	public let email: String
	public let fullName: String
	public let role: UserRole
	public let universityId: String
	public let active: Bool

	public init(
		id: UUID = UUID(),
		email: String,
		fullName: String,
		role: UserRole,
		universityId: String,
		active: Bool
	) {
		self.id = id
		self.email = email
		self.fullName = fullName
		self.role = role
		self.universityId = universityId
		self.active = active
	}
}