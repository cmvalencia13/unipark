import Foundation

@MainActor
public final class AppDIContainer {
	public static let shared = AppDIContainer()

	// MARK: - Repositories

	public lazy var authRepository: AuthRepository = StubAuthRepository()
	public lazy var passRepository: PassRepository = StubPassRepository()
	public lazy var scanRepository: ScanRepository = StubScanRepository()
	public lazy var lotRepository: LotRepository = StubLotRepository()
	public lazy var violationRepository: ViolationRepository = StubViolationRepository()

	// MARK: - Use Cases

	public var generatePassUseCase: GeneratePassUseCase {
		GeneratePassUseCase(passRepository: passRepository)
	}

	public var scanQRUseCase: ScanQRUseCase {
		ScanQRUseCase(scanRepository: scanRepository)
	}

	public var logEntryUseCase: LogEntryUseCase {
		LogEntryUseCase(scanRepository: scanRepository, lotRepository: lotRepository)
	}

	public var logExitUseCase: LogExitUseCase {
		LogExitUseCase(scanRepository: scanRepository, lotRepository: lotRepository)
	}

	public var manageLotUseCase: ManageLotUseCase {
		ManageLotUseCase(lotRepository: lotRepository)
	}

	public var manageViolationUseCase: ManageViolationUseCase {
		ManageViolationUseCase(violationRepository: violationRepository)
	}

	private init() {}
}

// MARK: - Stub Repositories

private final class StubAuthRepository: AuthRepository {
	private var cachedUser: User?

	func login() async throws -> User {
		let user = User(
			email: "carlos.test@unipark.edu",
			fullName: "Carlos Test",
			role: .driver,
			universityId: "2024001",
			active: true
		)
		cachedUser = user
		return user
	}

	func logout() async throws {
		cachedUser = nil
	}

	func currentUser() async throws -> User? {
		cachedUser
	}

	func refreshToken() async throws {
		return
	}
}

private final class StubPassRepository: PassRepository {
	private var cachedPass: Pass?

	func generatePass(vehicleId: UUID) async throws -> Pass {
		let now = Date.now
		let pass = Pass(
			userId: UUID(),
			vehicleId: vehicleId,
			issuedAt: now,
			expiresAt: now.addingTimeInterval(60),
			nonce: UUID().uuidString
		)
		cachedPass = pass
		return pass
	}

	func currentPass() async throws -> Pass? {
		cachedPass
	}
}

private final class StubScanRepository: ScanRepository {
	private var queuedScans: [Scan] = []

	func submitScan(
		passPayload: String,
		passSignature: String,
		direction: ScanDirection,
		lotId: UUID,
		idempotencyKey: String
	) async throws -> Scan {
		let scan = Scan(
			passId: UUID(uuidString: passPayload) ?? UUID(),
			guardId: UUID(),
			lotId: lotId,
			direction: direction,
			scannedAt: Date.now,
			idempotencyKey: idempotencyKey
		)
		queuedScans.append(scan)
		_ = passSignature
		return scan
	}

	func pendingScans() async throws -> [Scan] {
		queuedScans
	}

	func syncPendingScans() async throws {
		queuedScans.removeAll()
	}
}

private final class StubLotRepository: LotRepository {
	private var lots: [ParkingLot] = [
		ParkingLot(name: "Lote A", capacityTotal: 50, capacityUsed: 32, active: true),
		ParkingLot(name: "Lote B", capacityTotal: 30, capacityUsed: 30, active: true),
		ParkingLot(name: "Lote C", capacityTotal: 80, capacityUsed: 10, active: true)
	]

	func fetchLots() async throws -> [ParkingLot] {
		lots
	}

	func fetchLot(id: UUID) async throws -> ParkingLot {
		if let lot = lots.first(where: { $0.id == id }) {
			return lot
		}
		return lots[0]
	}

	func createLot(_ lot: ParkingLot) async throws -> ParkingLot {
		lots.append(lot)
		return lot
	}

	func updateLot(_ lot: ParkingLot) async throws -> ParkingLot {
		if let index = lots.firstIndex(where: { $0.id == lot.id }) {
			lots[index] = lot
		} else {
			lots.append(lot)
		}
		return lot
	}
}

private final class StubViolationRepository: ViolationRepository {
	private var violations: [Violation] = [
		Violation(
			vehicleId: UUID(),
			guardId: UUID(),
			lotId: UUID(),
			reason: "Estacionado en zona no autorizada",
			evidenceUrl: nil,
			status: .pending,
			createdAt: Date.now,
			resolvedBy: nil,
			resolvedAt: nil
		),
		Violation(
			vehicleId: UUID(),
			guardId: UUID(),
			lotId: UUID(),
			reason: "QR inválido o expirado",
			evidenceUrl: nil,
			status: .pending,
			createdAt: Date.now,
			resolvedBy: nil,
			resolvedAt: nil
		)
	]

	func reportViolation(vehicleId: UUID?, lotId: UUID?, reason: String, evidenceUrl: String?) async throws -> Violation {
		let violation = Violation(
			vehicleId: vehicleId,
			guardId: UUID(),
			lotId: lotId,
			reason: reason,
			evidenceUrl: evidenceUrl,
			status: .pending,
			createdAt: Date.now,
			resolvedBy: nil,
			resolvedAt: nil
		)
		violations.append(violation)
		return violation
	}

	func fetchViolations(status: ViolationStatus?) async throws -> [Violation] {
		guard let status else {
			return violations
		}
		return violations.filter { $0.status == status }
	}

	func resolveViolation(id: UUID, status: ViolationStatus) async throws -> Violation {
		let resolved = Violation(
			id: id,
			vehicleId: violations.first(where: { $0.id == id })?.vehicleId,
			guardId: violations.first(where: { $0.id == id })?.guardId ?? UUID(),
			lotId: violations.first(where: { $0.id == id })?.lotId,
			reason: violations.first(where: { $0.id == id })?.reason ?? "Violation",
			evidenceUrl: violations.first(where: { $0.id == id })?.evidenceUrl,
			status: status,
			createdAt: violations.first(where: { $0.id == id })?.createdAt ?? Date.now,
			resolvedBy: UUID(),
			resolvedAt: Date.now
		)

		if let index = violations.firstIndex(where: { $0.id == id }) {
			violations[index] = resolved
		} else {
			violations.append(resolved)
		}

		return resolved
	}
}