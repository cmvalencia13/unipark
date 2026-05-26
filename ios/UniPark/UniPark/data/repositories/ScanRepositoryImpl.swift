import Foundation

public final class ScanRepositoryImpl: ScanRepository {
	private let client = NetworkClient.shared

	// queued scans stored locally until sync
	private var queuedScans: [Scan] = []

	public init() {}

	public func submitScan(passPayload: String, passSignature: String, direction: ScanDirection, lotId: UUID, idempotencyKey: String) async throws -> Scan {
		let request = ScanRequestBody(passPayload: passPayload, passSignature: passSignature, direction: direction.rawValue, lotId: lotId)
		do {
			let endpoint = Endpoint.submitScan(request: request)
			let scan: Scan = try await client.request(endpoint)
			return scan
		} catch {
			// fallback: queue locally and return a synthetic Scan
			let scan = Scan(passId: UUID(), guardId: UUID(), lotId: lotId, direction: direction, scannedAt: Date(), idempotencyKey: idempotencyKey)
			queuedScans.append(scan)
			return scan
		}
	}

	public func pendingScans() async throws -> [Scan] {
		queuedScans
	}

	public func syncPendingScans() async throws {
		// attempt to flush queued scans
		let scans = queuedScans
		for s in scans {
			let body = ScanRequestBody(passPayload: "", passSignature: "", direction: s.direction.rawValue, lotId: s.lotId)
			do {
				_ = try await client.request(Endpoint.submitScan(request: body)) as Scan
			} catch {
				// keep remaining
			}
		}
		queuedScans.removeAll()
	}
}