import Foundation

public struct Violation: Identifiable, Codable, Sendable {
	public let id: UUID
	public let vehicleId: UUID?
	public let guardId: UUID
	public let lotId: UUID?
	public let reason: String
	public let evidenceUrl: String?
	public let status: ViolationStatus
	public let createdAt: Date
	public let resolvedBy: UUID?
	public let resolvedAt: Date?

	public init(
		id: UUID = UUID(),
		vehicleId: UUID? = nil,
		guardId: UUID,
		lotId: UUID? = nil,
		reason: String,
		evidenceUrl: String? = nil,
		status: ViolationStatus,
		createdAt: Date,
		resolvedBy: UUID? = nil,
		resolvedAt: Date? = nil
	) {
		self.id = id
		self.vehicleId = vehicleId
		self.guardId = guardId
		self.lotId = lotId
		self.reason = reason
		self.evidenceUrl = evidenceUrl
		self.status = status
		self.createdAt = createdAt
		self.resolvedBy = resolvedBy
		self.resolvedAt = resolvedAt
	}
}