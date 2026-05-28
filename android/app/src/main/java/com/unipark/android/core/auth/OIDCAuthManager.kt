package com.unipark.android.core.auth

import android.content.Context
import android.content.Intent
import dagger.hilt.android.qualifiers.ApplicationContext
import net.openid.appauth.AppAuthConfiguration
import net.openid.appauth.AuthorizationRequest
import net.openid.appauth.AuthorizationService
import net.openid.appauth.AuthorizationServiceConfiguration
import net.openid.appauth.ResponseTypeValues
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

@Singleton
class OIDCAuthManager @Inject constructor(
    private val config: OIDCConfig,
    @ApplicationContext context: Context,
    private val tokenStorage: TokenStorage,
) {
    private val authService = AuthorizationService(
        context,
        AppAuthConfiguration.Builder().build(),
    )

    fun buildLoginIntent(serviceConfig: AuthorizationServiceConfiguration): Intent {
        val request = AuthorizationRequest.Builder(
            serviceConfig,
            config.clientId,
            ResponseTypeValues.CODE,
            config.redirectUri,
        )
            .setScopes("openid", "profile", "email", "offline_access")
            .build()

        return authService.getAuthorizationRequestIntent(request)
    }

    suspend fun exchangeCode(request: net.openid.appauth.TokenRequest): String? =
        suspendCoroutine { continuation ->
            authService.performTokenRequest(request) { response, exception ->
                when {
                    response != null -> {
                        tokenStorage.save(response.accessToken, response.refreshToken)
                        continuation.resume(response.accessToken)
                    }
                    exception != null -> continuation.resumeWithException(exception)
                    else -> continuation.resume(null)
                }
            }
        }

    suspend fun refreshAccessToken(): String? {
        val refreshToken = tokenStorage.getRefreshToken() ?: return null
        val serviceConfig = discoverConfiguration()
        val request = net.openid.appauth.TokenRequest.Builder(
            serviceConfig,
            config.clientId,
        )
            .setGrantType("refresh_token")
            .setRefreshToken(refreshToken)
            .build()

        return exchangeCode(request)
    }

    suspend fun discoverConfiguration(): AuthorizationServiceConfiguration =
        suspendCoroutine { continuation ->
            AuthorizationServiceConfiguration.fetchFromIssuer(
                android.net.Uri.parse(config.issuerUrl),
            ) { serviceConfig, exception ->
                when {
                    serviceConfig != null -> continuation.resume(serviceConfig)
                    exception != null -> continuation.resumeWithException(exception)
                    else -> continuation.resumeWithException(IllegalStateException("OIDC discovery failed"))
                }
            }
        }
}
