import Foundation

// TODO: implemented in data/repositories/
public protocol PassRepository {
	func generatePass(vehicleId: UUID) async throws -> Pass
	func currentPass() async throws -> Pass?
}