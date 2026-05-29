import Foundation

// TODO: implemented in data/repositories/
public protocol LotRepository {
	func fetchLots() async throws -> [ParkingLot]
	func fetchLot(id: UUID) async throws -> ParkingLot
	func createLot(_ lot: ParkingLot) async throws -> ParkingLot
	func updateLot(_ lot: ParkingLot) async throws -> ParkingLot
}