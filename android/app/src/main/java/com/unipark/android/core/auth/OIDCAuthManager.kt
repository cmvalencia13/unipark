package com.unipark.android.core.auth

import android.content.Context
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

/**
 * Renovación de tokens contra **Auth0** usando el refresh token.
 * El login interactivo vive en [com.unipark.android.presentation.auth.AuthViewModel]
 * (WebAuthProvider). Aquí solo se renueva la sesión sin UI.
 */
@Singleton
class OIDCAuthManager @Inject constructor(
    private val config: OIDCConfig,
    @ApplicationContext context: Context,
    private val tokenStorage: TokenStorage,
) {
    private val account = Auth0(config.clientId, config.domain)
    private val authClient = AuthenticationAPIClient(account)

    /** Renueva el access token con el refresh token persistido; null si no hay sesión. */
    suspend fun refreshAccessToken(): String? {
        val refreshToken = tokenStorage.getRefreshToken() ?: return null

        val credentials: Credentials = suspendCoroutine { continuation ->
            authClient
                .renewAuth(refreshToken)
                .start(object : Callback<Credentials, AuthenticationException> {
                    override fun onSuccess(result: Credentials) = continuation.resume(result)
                    override fun onFailure(error: AuthenticationException) =
                        continuation.resumeWithException(error)
                })
        }

        tokenStorage.save(
            accessToken = credentials.accessToken,
            refreshToken = credentials.refreshToken ?: refreshToken,
            idToken = credentials.idToken,
        )
        return credentials.accessToken
    }
}
