import Foundation

/// Cliente HTTP para el recurso de lotes.
/// Endpoint disponible: GET /v1/lots
///
/// Respuesta del backend (ParkingLot entity):
/// {
///   "id": "uuid",
///   "name": "Parqueo Key",
///   "capacityTotal": 200,
///   "capacityUsed": 164,
///   "active": true
/// }
public final class LotAPIClient {
    public static let shared = LotAPIClient()
    private let network = NetworkClient.shared
    private init() {}

    public func fetchAllLots() async throws -> [ParkingLot] {
        return try await network.request(Endpoint.lots())
    }
}
