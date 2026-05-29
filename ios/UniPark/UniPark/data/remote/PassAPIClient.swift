import Foundation

/// Modelo que mapea la respuesta de GET /v1/passes/active
public struct ActivePassDTO: Decodable {
    public let passId: String
    public let nonce: String
    public let qrPayload: String   // "nonce:HMAC-base64" — listo para mostrar como QR
    public let expiresAt: String

    private enum CodingKeys: String, CodingKey {
        case passId, nonce, qrPayload, expiresAt
    }
}

/// Estado de parking del driver: ¿está dentro o fuera?
public struct DriverStatusDTO: Decodable {
    public let isParked: Bool
    public let lotName: String?
    public let direction: String?
    public let scannedAt: String?
}

public final class PassAPIClient {
    public static let shared = PassAPIClient()
    private let base = URL(string: FeatureFlags.backendBaseURL)!

    private init() {}

    /// GET /v1/passes/active — devuelve el pase activo con payload QR firmado por el backend.
    public func fetchActivePass() async throws -> ActivePassDTO {
        var request = URLRequest(url: base.appendingPathComponent("passes/active"))
        request.httpMethod = "GET"
        if let token = TokenStorage.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw NetworkError.noConnection }
        if http.statusCode == 401 { throw NetworkError.unauthorized }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("[PassAPI] Error \(http.statusCode): \(body)")
            throw NetworkError.serverError(http.statusCode)
        }
        return try JSONDecoder().decode(ActivePassDTO.self, from: data)
    }

    /// GET /v1/passes/my-status — estado de parking del conductor.
    public func fetchMyStatus() async throws -> DriverStatusDTO {
        var request = URLRequest(url: base.appendingPathComponent("passes/my-status"))
        request.httpMethod = "GET"
        if let token = TokenStorage.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else { throw NetworkError.noConnection }
        return try JSONDecoder().decode(DriverStatusDTO.self, from: data)
    }
}
