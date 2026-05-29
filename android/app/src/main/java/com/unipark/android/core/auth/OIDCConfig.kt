package com.unipark.android.core.auth

import android.net.Uri

/**
 * Configuración OIDC para autenticación con Keycloak.
 *
 * Entornos:
 *   Dev local  → http://10.0.2.2:8080/realms/unipark  (10.0.2.2 = localhost desde el emulador Android)
 *   Staging    → https://auth-staging.universidad.edu.sv/realms/unipark
 *   Producción → https://auth.universidad.edu.sv/realms/unipark
 *
 * Para levantar Keycloak local:
 *   docker compose --profile auth up keycloak
 */
data class OIDCConfig(
    val issuerUrl: String = "http://10.0.2.2:8080/realms/unipark",
    val clientId: String = "unipark-android",
    val redirectUri: Uri = Uri.parse("com.unipark.android:/oauth2redirect"),
)
