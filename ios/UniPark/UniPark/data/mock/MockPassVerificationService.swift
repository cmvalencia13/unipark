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
/// Phase 2: borrar esta clase y reemplazar la llamada en GuardViewModel por:
///   let result = try await passRepository.verify(payload: payload, lotId: lotId)
public final class MockPassVerificationService {
    public static let shared = MockPassVerificationService()
    private init() {}

    public func verify(payload: String, selectedLotName: String) async -> VerificationOutcome {
        // Simula latencia de verificación en servidor
        try? await Task.sleep(for: .milliseconds(800))

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
