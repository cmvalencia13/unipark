import Foundation

// TODO: implemented in data/repositories/
public protocol ViolationRepository {
	func reportViolation(vehicleId: UUID?, lotId: UUID?, reason: String, evidenceUrl: String?) async throws -> Violation
	func fetchViolations(status: ViolationStatus?) async throws -> [Violation]
	func resolveViolation(id: UUID, status: ViolationStatus) async throws -> Violation
}