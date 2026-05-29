import Foundation

/// Punto único de configuración para el entorno de UniPark.
public enum FeatureFlags {

    // MARK: - Entorno

    /// `false` → Login OIDC real con Keycloak, datos del backend.
    /// `true`  → Modo desarrollo local (sin Keycloak, stubs).
    public static let devMode: Bool = false

    /// URL base del backend Spring Boot.
    ///
    /// OPCIONES:
    ///   Simulador local:   "http://localhost:8081/v1"
    ///   ngrok (todos):     "https://xxxx.ngrok-free.app/v1"   ← reemplaza con tu URL
    ///   IP LAN (fallback): "http://10.74.10.127:8081/v1"
    ///   Producción:        "https://api.unipark.edu.sv/v1"
    ///
    /// Con ngrok el mismo string funciona en simulador, iPhone físico y cualquier red.
    // ✅ ngrok — funciona desde iPhone en cualquier red
    public static let backendBaseURL: String = "https://crested-monogram-ethanol.ngrok-free.dev/v1"
    // Simulador local (sin ngrok): "http://localhost:8081/v1"

    // MARK: - QR
    public static let qrRotationSeconds: Int = 60
    public static let qrUsesRealSignature: Bool = true

    // MARK: - Features Phase 2
    public static let nfcEnabled: Bool = false
    public static let pushNotificationsEnabled: Bool = false
}
