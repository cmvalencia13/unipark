import Foundation

public struct Vehicle: Identifiable, Codable, Sendable {
	public let id: UUID
	public let ownerId: UUID
	public let plateLast4: String
	public let makeModel: String?
	public let active: Bool

	public init(
		id: UUID = UUID(),
		ownerId: UUID,
		plateLast4: String,
		makeModel: String? = nil,
		active: Bool
	) {
		self.id = id
		self.ownerId = ownerId
		self.plateLast4 = plateLast4
		self.makeModel = makeModel
		self.active = active
	}
}