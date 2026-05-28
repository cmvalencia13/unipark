import Foundation

public struct ManageLotUseCase {
	private let lotRepository: LotRepository

	public init(lotRepository: LotRepository) {
		self.lotRepository = lotRepository
	}

	// MARK: - Queries

	public func fetchAll() async throws -> [ParkingLot] {
		try await lotRepository.fetchLots()
	}

	// MARK: - Mutations

	public func create(_ lot: ParkingLot) async throws -> ParkingLot {
		try await lotRepository.createLot(lot)
	}

	public func update(_ lot: ParkingLot) async throws -> ParkingLot {
		try await lotRepository.updateLot(lot)
	}
}