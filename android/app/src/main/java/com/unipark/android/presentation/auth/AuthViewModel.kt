package com.unipark.android.presentation.auth

import android.content.Context
import android.util.Base64
import androidx.lifecycle.ViewModel
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import com.unipark.android.core.auth.OIDCConfig
import com.unipark.android.core.auth.TokenStorage
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import org.json.JSONObject
import javax.inject.Inject

sealed interface AuthState {
    data object Idle : AuthState
    data object Loading : AuthState
    data class Authenticated(val email: String, val role: AppRole) : AuthState
    data class Error(val message: String) : AuthState
}

enum class AppRole { DRIVER, SECURITY_GUARD }

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val tokenStorage: TokenStorage,
    private val config: OIDCConfig,
) : ViewModel() {

    private val _authState = MutableStateFlow<AuthState>(AuthState.Idle)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    private var selectedRole: AppRole = AppRole.DRIVER

    private val account = Auth0(config.clientId, config.domain)

    fun selectRole(role: AppRole) {
        selectedRole = role
    }

    init {
        // Auto-login si ya existe un Access Token persistido.
        val token = tokenStorage.getAccessToken()
        if (!token.isNullOrBlank()) {
            val (email, role) = decodeIdentity(token)
            _authState.value = AuthState.Authenticated(email, role)
        }
    }

    /** Lanza el login universal de Auth0 (Custom Tabs + PKCE manejados por el SDK). */
    fun login(context: Context) {
        _authState.value = AuthState.Loading
        WebAuthProvider.login(account)
            .withScheme(config.scheme)
            .withScope(config.scope)
            .withAudience(config.audience)
            .start(context, object : Callback<Credentials, AuthenticationException> {
                override fun onSuccess(result: Credentials) {
                    tokenStorage.save(
                        accessToken = result.accessToken,
                        refreshToken = result.refreshToken,
                        idToken = result.idToken,
                    )
                    val (email, role) = decodeIdentity(result.accessToken)
                    _authState.value = AuthState.Authenticated(email, role)
                }

                override fun onFailure(error: AuthenticationException) {
                    _authState.value = AuthState.Error(error.getDescription())
                }
            })
    }

    fun logout(context: Context) {
        WebAuthProvider.logout(account)
            .withScheme(config.scheme)
            .start(context, object : Callback<Void?, AuthenticationException> {
                override fun onSuccess(result: Void?) {}
                override fun onFailure(error: AuthenticationException) {}
            })
        tokenStorage.clear()
        _authState.value = AuthState.Idle
    }

    // MARK: - JWT decode

    /**
     * Extrae email y rol del access token. El Auth0 Action emite los claims
     * namespaced (`$NS/email`, `$NS/realm_access.roles`), igual que consume el backend.
     */
    private fun decodeIdentity(accessToken: String): Pair<String, AppRole> {
        val claims = decodeJwtPayload(accessToken) ?: return ("" to selectedRole)

        val email = claims.optString(EMAIL_CLAIM, claims.optString("email", ""))

        val realmAccess = claims.optJSONObject(REALM_ACCESS_CLAIM)
            ?: claims.optJSONObject("realm_access")
        val roles = realmAccess?.optJSONArray("roles")
        val role = when {
            roles != null -> {
                var resolved = selectedRole
                for (i in 0 until roles.length()) {
                    when (roles.optString(i).lowercase()) {
                        "guard", "securityguard", "security_guard" -> {
                            resolved = AppRole.SECURITY_GUARD; break
                        }
                        "driver" -> { resolved = AppRole.DRIVER }
                    }
                }
                resolved
            }
            else -> selectedRole
        }
        return email to role
    }

    private fun decodeJwtPayload(token: String): JSONObject? {
        val parts = token.split(".")
        if (parts.size < 2) return null
        return try {
            val decoded = Base64.decode(parts[1], Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP)
            JSONObject(String(decoded, Charsets.UTF_8))
        } catch (e: Exception) {
            null
        }
    }

    private companion object {
        const val NS = "https://unipark.edu.sv"
        const val EMAIL_CLAIM = "$NS/email"
        const val REALM_ACCESS_CLAIM = "$NS/realm_access"
    }
}
