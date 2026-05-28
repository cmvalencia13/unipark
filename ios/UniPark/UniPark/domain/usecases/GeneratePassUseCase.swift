import Foundation

public struct GeneratePassUseCase {
	private let passRepository: PassRepository

	public init(passRepository: PassRepository) {
		self.passRepository = passRepository
	}

	// MARK: - Execution

	public func execute(vehicleId: UUID) async throws -> Pass {
		let pass = try await passRepository.generatePass(vehicleId: vehicleId)
		guard !pass.isExpired else {
			throw UseCaseError.generatedPassExpired
		}
		return pass
	}
}

private enum UseCaseError: Error {
	case generatedPassExpired
}