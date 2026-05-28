import Foundation

public struct Endpoint {
    public let path: String
    public let method: HTTPMethod
    public let body: Encodable?
    public let headers: [String: String]

    public init(path: String, method: HTTPMethod = .GET, body: Encodable? = nil, headers: [String: String] = [:]) {
        self.path = path
        self.method = method
        self.body = body
        self.headers = headers
    }

    // MARK: - Factories

    public static func lots() -> Endpoint {
        Endpoint(path: "lots", method: .GET)
    }

    public static func createPass(vehicleId: UUID) -> Endpoint {
        let body = CreatePassBody(vehicleId: vehicleId)
        return Endpoint(path: "passes", method: .POST, body: body)
    }

    public static func submitScan(request: ScanRequestBody) -> Endpoint {
        Endpoint(path: "scans", method: .POST, body: request)
    }

    public static func violations(status: String? = nil) -> Endpoint {
        if let status = status {
            return Endpoint(path: "violations?status=\(status)", method: .GET)
        }
        return Endpoint(path: "violations", method: .GET)
    }

    public static func reportViolation(request: ViolationRequestBody) -> Endpoint {
        Endpoint(path: "violations", method: .POST, body: request)
    }
}

// MARK: - Request Bodies

fileprivate struct CreatePassBody: Codable {
    let vehicleId: UUID
}

public struct ScanRequestBody: Codable {
    public let passPayload: String
    public let passSignature: String
    public let direction: String
    public let lotId: UUID

    public init(passPayload: String, passSignature: String, direction: String, lotId: UUID) {
        self.passPayload = passPayload
        self.passSignature = passSignature
        self.direction = direction
        self.lotId = lotId
    }
}

public struct ViolationRequestBody: Codable {
    public let vehicleId: UUID?
    public let lotId: UUID?
    public let reason: String
    public let evidenceUrl: String?

    public init(vehicleId: UUID?, lotId: UUID?, reason: String, evidenceUrl: String? = nil) {
        self.vehicleId = vehicleId
        self.lotId = lotId
        self.reason = reason
        self.evidenceUrl = evidenceUrl
    }
}
