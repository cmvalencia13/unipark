import Foundation

@MainActor
public final class AppDIContainer {
	public static let shared = AppDIContainer()

	// MARK: - Repositories

	public lazy var authRepository: AuthRepository = AuthRepositoryImpl()
	public lazy var passRepository: PassRepository = PassRepositoryImpl()
	public lazy var scanRepository: ScanRepository = ScanRepositoryImpl()
	public lazy var lotRepository: LotRepository = LotRepositoryImpl()
	public lazy var violationRepository: ViolationRepository = ViolationRepositoryImpl()

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