import Foundation

public final class PassRepositoryImpl: PassRepository {
	private let client = NetworkClient.shared

	// fallback store
	private var current: Pass?

	public init() {}

	public func generatePass(vehicleId: UUID) async throws -> Pass {
		do {
			let endpoint = Endpoint.createPass(vehicleId: vehicleId)
			let pass: Pass = try await client.request(endpoint)
			current = pass
			return pass
		} catch {
			// fallback: produce a local pass valid for 60s
			let pass = Pass(userId: UUID(), vehicleId: vehicleId, issuedAt: Date(), expiresAt: Date().addingTimeInterval(60), nonce: UUID().uuidString)
			current = pass
			return pass
		}
	}

	public func currentPass() async throws -> Pass? {
		// try to get current from server, otherwise return cached
		do {
			let endpoint = Endpoint(path: "passes/current", method: .GET)
			let pass: Pass = try await client.request(endpoint)
			current = pass
			return pass
		} catch {
			return current
		}
	}
}