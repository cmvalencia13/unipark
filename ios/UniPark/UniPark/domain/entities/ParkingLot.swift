import Foundation

public struct ParkingLot: Identifiable, Codable, Sendable, Equatable {
	public let id: UUID
	public let name: String
	public let capacityTotal: Int
	public let capacityUsed: Int
	public let active: Bool

	public var availableSpots: Int {
		max(capacityTotal - capacityUsed, 0)
	}

	public var occupancyPercentage: Double {
		guard capacityTotal > 0 else { return 0 }
		return Double(capacityUsed) / Double(capacityTotal)
	}

	public var isFull: Bool {
		capacityUsed >= capacityTotal
	}

	public init(
		id: UUID = UUID(),
		name: String,
		capacityTotal: Int,
		capacityUsed: Int,
		active: Bool
	) {
		self.id = id
		self.name = name
		self.capacityTotal = capacityTotal
		self.capacityUsed = capacityUsed
		self.active = active
	}

	// MARK: - Dev stubs (placeholder mientras carga del backend)
	public static let stubs: [ParkingLot] = [
		ParkingLot(name: "Parqueo Key",    capacityTotal: 200, capacityUsed: 0, active: true),
		ParkingLot(name: "Parqueo Matías", capacityTotal: 120, capacityUsed: 0, active: true),
	]
}