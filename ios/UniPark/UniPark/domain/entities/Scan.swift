import Foundation

public struct Scan: Identifiable, Codable, Sendable {
	public let id: UUID
	public let passId: UUID
	public let guardId: UUID
	public let lotId: UUID
	public let direction: ScanDirection
	public let scannedAt: Date
	public let idempotencyKey: String

	public init(
		id: UUID = UUID(),
		passId: UUID,
		guardId: UUID,
		lotId: UUID,
		direction: ScanDirection,
		scannedAt: Date,
		idempotencyKey: String
	) {
		self.id = id
		self.passId = passId
		self.guardId = guardId
		self.lotId = lotId
		self.direction = direction
		self.scannedAt = scannedAt
		self.idempotencyKey = idempotencyKey
	}
}