import Foundation

public struct ManageViolationUseCase {
	private let violationRepository: ViolationRepository

	public init(violationRepository: ViolationRepository) {
		self.violationRepository = violationRepository
	}

	// MARK: - Reporting

	public func report(
		vehicleId: UUID?,
		lotId: UUID?,
		reason: String,
		evidenceUrl: String?
	) async throws -> Violation {
		try await violationRepository.reportViolation(
			vehicleId: vehicleId,
			lotId: lotId,
			reason: reason,
			evidenceUrl: evidenceUrl
		)
	}

	// MARK: - Queries

	public func fetchPending() async throws -> [Violation] {
		try await violationRepository.fetchViolations(status: .pending)
	}

	// MARK: - Resolution

	public func approve(id: UUID) async throws -> Violation {
		try await violationRepository.resolveViolation(id: id, status: .approved)
	}

	public func dismiss(id: UUID) async throws -> Violation {
		try await violationRepository.resolveViolation(id: id, status: .dismissed)
	}
}