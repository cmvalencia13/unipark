import Foundation

/// Punto único de configuración para el entorno de UniPark.
///
/// Día de conexión al backend:
///   1. Cambia `devMode` a `false`
///   2. Cambia `backendBaseURL` a la URL real del servidor
///   3. Activa `nfcEnabled` cuando tengas entitlement + backend
///   4. Activa `pushNotificationsEnabled` cuando tengas APNs
///
/// Nada más debe cambiar — todos los ViewModels y APIClients
/// leen estas propiedades desde aquí.
public enum FeatureFlags {

    // MARK: - Entorno

    /// `true` → DevRoleSelector activo, sin auth real, datos stub.
    /// `false` → Login OIDC real, datos del backend.
    public static let devMode: Bool = true

    /// URL base del backend Spring Boot.
    /// Dev local:        "http://localhost:8080/v1"
    /// Staging:          "https://api-staging.unipark.edu.sv/v1"
    /// Producción:       "https://api.unipark.edu.sv/v1"
    public static let backendBaseURL: String = "http://localhost:8080/v1"

    // MARK: - Features Phase 2 (post-backend)

    /// NFC habilitado. Requiere entitlement com.apple.developer.nfc.readersession.formats
    /// y endpoint de validación en el backend. Solo funciona en dispositivo físico.
    public static let nfcEnabled: Bool = false

    /// Push notifications. Requiere certificado APNs y endpoint /push en el backend.
    public static let pushNotificationsEnabled: Bool = false

    // MARK: - QR

    /// Segundos antes de que el QR rote y genere un nuevo payload.
    public static let qrRotationSeconds: Int = 60
}
