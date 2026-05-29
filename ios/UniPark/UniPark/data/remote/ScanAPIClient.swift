import Foundation

public final class ScanAPIClient {
    public static let shared = ScanAPIClient()
    private let base = URL(string: FeatureFlags.backendBaseURL)!

    /// Último mensaje de error del backend (400), para mostrarlo en la UI.
    public static var lastErrorMessage: String? = nil

    private init() {}

    public func recordScan(
        qrPayload: String,
        lotId: UUID,
        direction: ScanDirection
    ) async throws -> RemoteScanResponse {
        var request = URLRequest(url: base.appendingPathComponent("scans"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "Idempotency-Key")
        if let token = TokenStorage.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = RemoteScanRequest(
            qrPayload: qrPayload,
            lotId: lotId.uuidString,
            direction: direction == .entry ? "ENTRY" : "EXIT"
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw NetworkError.noConnection }

        if (200...299).contains(http.statusCode) {
            ScanAPIClient.lastErrorMessage = nil
            return try JSONDecoder().decode(RemoteScanResponse.self, from: data)
        }

        // Intentar extraer el mensaje del backend
        if let errorBody = try? JSONDecoder().decode(BackendErrorBody.self, from: data) {
            ScanAPIClient.lastErrorMessage = errorBody.message
        } else {
            ScanAPIClient.lastErrorMessage = String(data: data, encoding: .utf8)
        }
        throw NetworkError.clientError(http.statusCode)
    }
}

// MARK: - DTOs

public struct RemoteScanRequest: Codable {
    public let qrPayload: String
    public let lotId: String
    public let direction: String
}

public struct RemoteScanResponse: Codable {
    public let id: UUID
    public let direction: String
    public let scannedAt: String
}

private struct BackendErrorBody: Decodable {
    let message: String
    let status: Int?
}
