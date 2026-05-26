import Foundation

public struct LogEntryUseCase {
	private let scanQRUseCase: ScanQRUseCase
	private let lotRepository: LotRepository

	public init(scanRepository: ScanRepository, lotRepository: LotRepository) {
		self.scanQRUseCase = ScanQRUseCase(scanRepository: scanRepository)
		self.lotRepository = lotRepository
	}

	// MARK: - Execution

	public func execute(
		passPayload: String,
		passSignature: String,
		lotId: UUID
	) async throws -> (scan: Scan, lot: ParkingLot) {
		let scan = try await scanQRUseCase.execute(
			passPayload: passPayload,
			passSignature: passSignature,
			direction: .entry,
			lotId: lotId
		)
		let lot = try await lotRepository.fetchLot(id: lotId)
		return (scan: scan, lot: lot)
	}
}