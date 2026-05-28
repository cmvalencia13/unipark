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
        guard (200...299).contains(http.statusCode) else { throw NetworkError.unauthorized }
        return try JSONDecoder().decode(ActivePassDTO.self, from: data)
    }
}
