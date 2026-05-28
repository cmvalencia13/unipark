import Foundation

/// Punto único de configuración para el entorno de UniPark.
public enum FeatureFlags {

    // MARK: - Entorno

    /// `false` → Login OIDC real con Keycloak, datos del backend.
    /// `true`  → Modo desarrollo local (sin Keycloak, stubs).
    public static let devMode: Bool = false

    /// URL base del backend Spring Boot.
    /// Dev local:   "http://localhost:8081/v1"
    /// Staging:     "https://api-staging.unipark.edu.sv/v1"
    /// Producción:  "https://api.unipark.edu.sv/v1"
    public static let backendBaseURL: String = "http://localhost:8081/v1"

    // MARK: - QR

    /// Segundos antes de que el QR solicite un nuevo payload al backend.
    public static let qrRotationSeconds: Int = 60

    /// true → backend genera y firma el payload; iOS solo lo muestra.
    public static let qrUsesRealSignature: Bool = true

    // MARK: - Features Phase 2

    /// NFC habilitado. Requiere entitlement + backend.
    public static let nfcEnabled: Bool = false

    /// Push notifications. Requiere APNs + endpoint /push.
    public static let pushNotificationsEnabled: Bool = false
}
