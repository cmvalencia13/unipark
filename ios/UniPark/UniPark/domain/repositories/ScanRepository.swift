import Foundation

// TODO: implemented in data/repositories/
public protocol ScanRepository {
	func submitScan(
		passPayload: String,
		passSignature: String,
		direction: ScanDirection,
		lotId: UUID,
		idempotencyKey: String
	) async throws -> Scan

	func pendingScans() async throws -> [Scan]
	func syncPendingScans() async throws
}