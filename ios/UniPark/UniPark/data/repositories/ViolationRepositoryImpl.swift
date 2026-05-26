import Foundation

public final class ViolationRepositoryImpl: ViolationRepository {
	private let client = NetworkClient.shared

	private var fallbackViolations: [Violation] = [
		Violation(vehicleId: UUID(), guardId: UUID(), lotId: UUID(), reason: "Estacionado en zona no autorizada", evidenceUrl: nil, status: .pending, createdAt: Date(), resolvedBy: nil, resolvedAt: nil),
		Violation(vehicleId: UUID(), guardId: UUID(), lotId: UUID(), reason: "QR inválido o expirado", evidenceUrl: nil, status: .pending, createdAt: Date(), resolvedBy: nil, resolvedAt: nil)
	]

	public init() {}

	public func reportViolation(vehicleId: UUID?, lotId: UUID?, reason: String, evidenceUrl: String?) async throws -> Violation {
		let body = ViolationRequestBody(vehicleId: vehicleId, lotId: lotId, reason: reason, evidenceUrl: evidenceUrl)
		do {
			let endpoint = Endpoint.reportViolation(request: body)
			let violation: Violation = try await client.request(endpoint)
			return violation
		} catch {
			let violation = Violation(vehicleId: vehicleId, guardId: UUID(), lotId: lotId, reason: reason, evidenceUrl: evidenceUrl, status: .pending, createdAt: Date(), resolvedBy: nil, resolvedAt: nil)
			fallbackViolations.append(violation)
			return violation
		}
	}

	public func fetchViolations(status: ViolationStatus?) async throws -> [Violation] {
		do {
			let endpoint = Endpoint.violations(status: status?.rawValue)
			let violations: [Violation] = try await client.request(endpoint)
			return violations
		} catch {
			guard let status else { return fallbackViolations }
			return fallbackViolations.filter { $0.status == status }
		}
	}

	public func resolveViolation(id: UUID, status: ViolationStatus) async throws -> Violation {
		// attempt server resolution
		do {
			let endpoint = Endpoint(path: "violations/\(id.uuidString)/resolve", method: .PATCH, body: ["status": status.rawValue])
			let resolved: Violation = try await client.request(endpoint)
			return resolved
		} catch {
			// local resolution
			let resolved = Violation(id: id, vehicleId: fallbackViolations.first(where: { $0.id == id })?.vehicleId, guardId: UUID(), lotId: fallbackViolations.first(where: { $0.id == id })?.lotId, reason: fallbackViolations.first(where: { $0.id == id })?.reason ?? "Violación", evidenceUrl: fallbackViolations.first(where: { $0.id == id })?.evidenceUrl, status: status, createdAt: fallbackViolations.first(where: { $0.id == id })?.createdAt ?? Date(), resolvedBy: UUID(), resolvedAt: Date())
			if let idx = fallbackViolations.firstIndex(where: { $0.id == id }) {
				fallbackViolations[idx] = resolved
			} else {
				fallbackViolations.append(resolved)
			}
			return resolved
		}
	}
}