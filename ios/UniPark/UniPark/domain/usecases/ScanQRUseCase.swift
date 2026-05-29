import Foundation

public struct ScanQRUseCase {
	private let scanRepository: ScanRepository

	public init(scanRepository: ScanRepository) {
		self.scanRepository = scanRepository
	}

	// MARK: - Execution

	public func execute(
		passPayload: String,
		passSignature: String,
		direction: ScanDirection,
		lotId: UUID
	) async throws -> Scan {
		let idempotencyKey = UUID().uuidString

		do {
			return try await scanRepository.submitScan(
				passPayload: passPayload,
				passSignature: passSignature,
				direction: direction,
				lotId: lotId,
				idempotencyKey: idempotencyKey
			)
		} catch {
			try await scanRepository.syncPendingScans()
			throw error
		}
	}
}