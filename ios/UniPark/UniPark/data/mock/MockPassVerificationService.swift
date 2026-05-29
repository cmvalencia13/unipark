import Foundation

// MARK: - Verification Result

/// Resultado de verificar un pase QR.
/// Phase 2: reemplazar MockPassVerificationService por una llamada real a
/// POST /passes/verify → { outcome, driverName, lotId, expiresAt }
public enum VerificationOutcome: Equatable {
    case valid(driverName: String, lotId: UUID)
    case expired
    case alreadyUsed
    case wrongLot(expected: String)
    case revoked
    case invalidSignature
}

extension VerificationOutcome {
    /// Texto corto para mostrar al guardia.
    public var displayTitle: String {
        switch self {
        case .valid:            return "Acceso autorizado"
        case .expired:          return "QR expirado"
        case .alreadyUsed:      return "QR ya utilizado"
        case .wrongLot:         return "Lote incorrecto"
        case .revoked:          return "Pase revocado"
        case .invalidSignature: return "QR inválido"
        }
    }

    /// Detalle explicativo para el guardia.
    public var displayDetail: String {
        switch self {
        case .valid(_, _):
            return "Permiso vigente. Permitir acceso."
        case .expired:
            return "El código expiró. Pedir al conductor que regenere su QR."
        case .alreadyUsed:
            return "Este código ya fue usado hoy. Posible duplicado."
        case .wrongLot(let expected):
            return "El pase es para \(expected). Este vehículo no corresponde aquí."
        case .revoked:
            return "El pase fue cancelado por administración."
        case .invalidSignature:
            return "El código no es de UniPark o fue alterado."
        }
    }

    public var isValid: Bool {
        if case .valid = self { return true }
        return false
    }
}

// MARK: - Service

/// Servicio mock de verificación de pases.
/// Simula latencia de red (~0.8s) y retorna resultados variados según el payload.
///
/// Convención de payloads de prueba:
///   "UNIPARK-..."         → válido (driver demo)
///   "EXPIRED-..."         → expirado
///   "USED-..."            → ya utilizado
///   "WRONG-LOT-..."       → lote incorrecto
///   "REVOKED-..."         → revocado
///   cualquier otro        → firma inválida
///
/// Phase 2: reemplazar con llamada real a POST /v1/scans via ScanAPIClient.
///
/// Formato real del QR (backend ScanValidationService):
///   payload = "nonce:HMAC-SHA256-base64-signature"
///   El backend valida: firma, expiración del pass, idempotency.
///
/// Para migrar:
///   1. El driver genera el payload via POST /v1/passes → recibe nonce + expiresAt
///   2. iOS construye: "\(nonce):\(signature)" donde signature viene del backend
///   3. El guardia escanea → iOS llama ScanAPIClient.recordScan(qrPayload:lotId:direction:)
///   4. El backend devuelve Scan o lanza error → mapear a VerificationOutcome
///   5. Borrar MockPassVerificationService
public final class MockPassVerificationService {
    public static let shared = MockPassVerificationService()
    private init() {}

    public func verify(payload: String, selectedLotName: String) async -> VerificationOutcome {
        // Simula latencia de verificación (~red real)
        try? await Task.sleep(for: .milliseconds(800))

        // Formato real del backend: "nonce:signature" (dos partes separadas por ":")
        // Si el payload tiene ese formato, lo tratamos como válido en Phase 1
        let parts = payload.split(separator: ":")
        if parts.count == 2 {
            return .valid(driverName: "María García", lotId: UUID())
        }

        // Prefijos de prueba para la demo
        if payload.hasPrefix("UNIPARK-") {
            return .valid(driverName: "María García", lotId: UUID())
        } else if payload.hasPrefix("EXPIRED-") {
            return .expired
        } else if payload.hasPrefix("USED-") {
            return .alreadyUsed
        } else if payload.hasPrefix("WRONG-LOT-") {
            return .wrongLot(expected: "Parqueo Matías")
        } else if payload.hasPrefix("REVOKED-") {
            return .revoked
        } else {
            return .invalidSignature
        }
    }
}
