import Foundation

/// Cliente HTTP para registrar escaneos de entrada/salida.
/// Endpoint: POST /v1/scans
/// Auth requerida: Bearer token con rol GUARD
///
/// Request body:
/// {
///   "qrPayload": "nonce:HMAC-SHA256-signature",
///   "lotId": "uuid",
///   "direction": "ENTRY" | "EXIT"
/// }
///
/// Headers requeridos:
///   Authorization: Bearer <jwt>
///   Idempotency-Key: <uuid>   ← evita duplicados si hay retry
///
/// Respuesta: objeto Scan con id, pass, guard, lot, direction, scannedAt
public final class ScanAPIClient {
    public static let shared = ScanAPIClient()
    private let network = NetworkClient.shared
    private init() {}

    public func recordScan(
        qrPayload: String,
        lotId: UUID,
        direction: ScanDirection
    ) async throws -> RemoteScanResponse {
        let idempotencyKey = UUID().uuidString
        let body = RemoteScanRequest(
            qrPayload: qrPayload,
            lotId: lotId,
            direction: direction == .entry ? "ENTRY" : "EXIT"
        )
        let endpoint = Endpoint(
            path: "scans",
            method: .POST,
            body: body,
            headers: ["Idempotency-Key": idempotencyKey]
        )
        return try await network.request(endpoint)
    }
}

// MARK: - DTOs

public struct RemoteScanRequest: Codable {
    public let qrPayload: String
    public let lotId: UUID
    public let direction: String
}

public struct RemoteScanResponse: Codable {
    public let id: UUID
    public let direction: String
    public let scannedAt: String
    // pass y guard se omiten — iOS no los necesita en la UI
}
