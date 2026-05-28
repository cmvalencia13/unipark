import Foundation

public struct Pass: Identifiable, Codable, Sendable {
	public let id: UUID
	public let userId: UUID
	public let vehicleId: UUID
	public let issuedAt: Date
	public let expiresAt: Date
	public let nonce: String

	public var isExpired: Bool {
		expiresAt <= Date.now
	}

	public init(
		id: UUID = UUID(),
		userId: UUID,
		vehicleId: UUID,
		issuedAt: Date,
		expiresAt: Date,
		nonce: String
	) {
		self.id = id
		self.userId = userId
		self.vehicleId = vehicleId
		self.issuedAt = issuedAt
		self.expiresAt = expiresAt
		self.nonce = nonce
	}
}