package com.unipark.android.core.auth

/**
 * Configuración OIDC para autenticación con **Auth0**.
 *
 * Reemplaza la configuración contra Keycloak. El SDK de Auth0 (com.auth0.android)
 * maneja PKCE, el navegador (Custom Tabs) y el intercambio de código internamente.
 *
 * ── Valores a completar por el responsable de Auth0 ──────────────────────────
 * `domain`   → dominio del tenant, p.ej. "unipark.us.auth0.com" (SIN https://).
 *              DEBE coincidir con manifestPlaceholders["auth0Domain"] en build.gradle.kts.
 * `clientId` → Client ID de la app **Native** "UniPark Android" en el dashboard.
 * `audience` → Identifier de la API en Auth0 ("https://api.unipark.edu.sv").
 *              OBLIGATORIO: sin audience el access token es opaco y el backend lo rechaza.
 * `scheme`   → esquema del callback; debe coincidir con manifestPlaceholders["auth0Scheme"].
 *
 * Callback a registrar en Auth0 (Allowed Callback URLs / Logout URLs):
 *   {scheme}://{domain}/android/{applicationId}/callback
 *   p.ej. com.unipark.android://TU_DOMINIO.us.auth0.com/android/com.unipark.android/callback
 */
data class OIDCConfig(
    val domain: String = "dev-5ndrp8gm0rm3r0mw.us.auth0.com",
    val clientId: String = "cs3CdYX3JKCmIUnCuLbY9S43qAvGDWQI",
    val audience: String = "https://api.unipark.edu.sv",
    val scheme: String = "com.unipark.android",
    val scope: String = "openid profile email offline_access",
)
