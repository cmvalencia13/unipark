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

    public init(container: AppDIContainer = .shared) {
        self.authRepository = container.authRepository
        self.manageLotUseCase = container.manageLotUseCase
    }

    // MARK: - Loading

    public func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            if let currentUser = try await authRepository.currentUser() {
                user = currentUser
            } else {
                user = try await authRepository.login()
            }

            lots = try await manageLotUseCase.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    public func refresh() async {
        await loadData()
    }
}
