import Foundation

public final class LotRepositoryImpl: LotRepository {
    private let apiClient = LotAPIClient.shared

    public init() {}

    /// Carga todos los lotes del backend.
    /// Si el backend no está disponible, retorna los stubs locales
    /// para que la app siga funcionando en dev/offline.
    public func fetchLots() async throws -> [ParkingLot] {
        do {
            return try await apiClient.fetchAllLots()
        } catch {
            // Fallback a stubs mientras el backend no esté disponible
            return ParkingLot.stubs
        }
    }

    public func fetchLot(id: UUID) async throws -> ParkingLot {
        let lots = try await fetchLots()
        guard let lot = lots.first(where: { $0.id == id }) else {
            throw NetworkError.clientError(404)
        }
        return lot
    }

    public func createLot(_ lot: ParkingLot) async throws -> ParkingLot {
        // Phase 2: POST /v1/lots (requiere rol admin)
        return lot
    }

    public func updateLot(_ lot: ParkingLot) async throws -> ParkingLot {
        // Phase 2: PATCH /v1/lots/:id (requiere rol admin)
        return lot
    }
}
