import Foundation
import Observation

@MainActor
@Observable
public final class DriverDashboardViewModel {
    private let authRepository: AuthRepository
    private let manageLotUseCase: ManageLotUseCase

    public var user: User?
    public var lots: [ParkingLot] = []
    public var isLoading: Bool = false
    public var errorMessage: String?

    // UI stubs – replaced by real data when backend is ready
    public var activePass: ActivePassDisplay? = ActivePassDisplay(
        lotName: "Commuter Zone A",
        expiryDateString: "Dec 31, 2026 • Auto-Renew ON"
    )
    public var currentVehicle: VehicleDisplay? = VehicleDisplay(
        plate: "Lot B",
        details: "Spot 42 • Level 2"
    )

    public init(container: AppDIContainer = .shared) {
        self.authRepository = container.authRepository
        self.manageLotUseCase = container.manageLotUseCase
    }

    // MARK: - Loading

    public func loadData() async {
        isLoading = true
        errorMessage = nil

        // Load cached user if available — never trigger login() from here
        // (login is handled by RootView / OIDCAuthManager)
        if let cached = try? await authRepository.currentUser() {
            user = cached
        }

        // Load lots; fall back to stubs on network error
        do {
            let fetched = try await manageLotUseCase.fetchAll()
            if !fetched.isEmpty { lots = fetched }
        } catch {
            // Backend not running — use stub lots so UI renders
            if lots.isEmpty {
                lots = ParkingLot.stubs
            }
        }

        isLoading = false
    }

    public func refresh() async {
        await loadData()
    }
}
