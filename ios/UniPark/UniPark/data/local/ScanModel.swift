import Foundation
import SwiftData

@Model
public final class PendingScan {
	public var id: UUID
	public var passPayload: String
	public var passSignature: String
	public var direction: String
	public var lotId: UUID
	public var scannedAt: Date
	public var idempotencyKey: String
	public var synced: Bool
	public var retryCount: Int

	public init(
		id: UUID = UUID(),
		passPayload: String,
		passSignature: String,
		direction: String,
		lotId: UUID,
		scannedAt: Date,
		idempotencyKey: String,
		synced: Bool = false,
		retryCount: Int = 0
	) {
		self.id = id
		self.passPayload = passPayload
		self.passSignature = passSignature
		self.direction = direction
		self.lotId = lotId
		self.scannedAt = scannedAt
		self.idempotencyKey = idempotencyKey
		self.synced = synced
		self.retryCount = retryCount
	}
}