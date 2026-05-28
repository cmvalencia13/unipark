import Foundation
import SwiftData

public final class ScanRepositoryImpl: ScanRepository {
	private let client = NetworkClient.shared
	private let localStore = SwiftDataStack.shared

	public init() {}

	public func submitScan(passPayload: String, passSignature: String, direction: ScanDirection, lotId: UUID, idempotencyKey: String) async throws -> Scan {
		let request = ScanRequestBody(passPayload: passPayload, passSignature: passSignature, direction: direction.rawValue, lotId: lotId)
		do {
			let endpoint = Endpoint.submitScan(request: request)
			let scan: Scan = try await client.request(endpoint)
			return scan
		} catch {
			let pending = PendingScan(
				passPayload: passPayload,
				passSignature: passSignature,
				direction: direction.rawValue,
				lotId: lotId,
				scannedAt: Date(),
				idempotencyKey: idempotencyKey,
				synced: false,
				retryCount: 0
			)
			try? localStore.savePendingScan(pending)

			let scan = Scan(
				passId: UUID(uuidString: passPayload) ?? UUID(),
				guardId: UUID(),
				lotId: lotId,
				direction: direction,
				scannedAt: pending.scannedAt,
				idempotencyKey: idempotencyKey
			)
			return scan
		}
	}

	public func pendingScans() async throws -> [Scan] {
		let pending = try localStore.fetchPendingScans()
		return pending.map { item in
			Scan(
				id: item.id,
				passId: UUID(uuidString: item.passPayload) ?? UUID(),
				guardId: UUID(),
				lotId: item.lotId,
				direction: ScanDirection(rawValue: item.direction) ?? .entry,
				scannedAt: item.scannedAt,
				idempotencyKey: item.idempotencyKey
			)
		}
	}

	public func syncPendingScans() async throws {
		let pending = try localStore.fetchPendingScans()

		for item in pending where !item.synced {
			if item.retryCount >= 3 {
				continue
			}

			let body = ScanRequestBody(
				passPayload: item.passPayload,
				passSignature: item.passSignature,
				direction: item.direction,
				lotId: item.lotId
			)

			do {
				let _: Scan = try await client.request(Endpoint.submitScan(request: body))
				try localStore.markSynced(item)
			} catch {
				item.retryCount += 1
				try? localStore.context.save()
			}
		}

		try? localStore.deleteSynced()
	}
}