import Foundation

public enum NetworkError: LocalizedError, Equatable {
    case unauthorized
    case rateLimited
    case clientError(Int)
    case serverError(Int)
    case decodingError
    case noConnection

    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "No autorizado. Por favor inicia sesión nuevamente."
        case .rateLimited:
            return "Demasiadas solicitudes. Por favor inténtalo más tarde."
        case .clientError(let code):
            return "Error del cliente (código \(code))."
        case .serverError(let code):
            return "Error del servidor (código \(code))."
        case .decodingError:
            return "Error procesando la respuesta del servidor."
        case .noConnection:
            return "Sin conexión. Comprueba tu conexión a Internet."
        }
    }
}
