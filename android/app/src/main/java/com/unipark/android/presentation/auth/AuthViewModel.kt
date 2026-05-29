package com.unipark.android.presentation.auth

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.lifecycle.ViewModel
import com.unipark.android.data.security.TokenManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import net.openid.appauth.AppAuthConfiguration
import net.openid.appauth.AuthorizationException
import net.openid.appauth.AuthorizationRequest
import net.openid.appauth.AuthorizationResponse
import net.openid.appauth.AuthorizationService
import net.openid.appauth.AuthorizationServiceConfiguration
import net.openid.appauth.ResponseTypeValues
import java.net.HttpURLConnection
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
    private val tokenManager: TokenManager
) : ViewModel() {

    private val _authState = MutableStateFlow<AuthState>(AuthState.Idle)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    private val authServiceConfiguration = AuthorizationServiceConfiguration(
        Uri.parse("http://10.0.2.2:8082/realms/unipark/protocol/openid-connect/auth"),
        Uri.parse("http://10.0.2.2:8082/realms/unipark/protocol/openid-connect/token")
    )

    private val appAuthConfig = AppAuthConfiguration.Builder()
        .setConnectionBuilder { uri -> java.net.URL(uri.toString()).openConnection() as HttpURLConnection }
        .build()


    init {
        // Auto-login si ya existe un Access Token persistido
        val token = tokenManager.getAccessToken()
        if (!token.isNullOrBlank()) {
            _authState.value = AuthState.Authenticated("user@university.edu")
        }
    }

    fun getAuthIntent(context: Context): Intent {
        val authRequest = AuthorizationRequest.Builder(
            authServiceConfiguration,
            "unipark-mobile",
            ResponseTypeValues.CODE,
            Uri.parse("com.unipark.android:/oauth2redirect")
        ).setScope("openid profile email offline_access")
         .build()

        val authService = AuthorizationService(context, appAuthConfig)
        val intent = authService.getAuthorizationRequestIntent(authRequest)
        authService.dispose()
        return intent
    }

    fun handleAuthResult(context: Context, data: Intent?) {
        if (data == null) {
            _authState.value = AuthState.Error("No authentication data received")
            return
        }

        _authState.value = AuthState.Loading

        val response = AuthorizationResponse.fromIntent(data)
        val exception = AuthorizationException.fromIntent(data)

        if (exception != null) {
            _authState.value = AuthState.Error(exception.localizedMessage ?: "Authorization failed")
            return
        }

        if (response != null) {
            val authService = AuthorizationService(context, appAuthConfig)
            authService.performTokenRequest(
                response.createTokenExchangeRequest()
            ) { tokenResponse, tokenException ->
                authService.dispose()
                if (tokenException != null) {
                    _authState.value = AuthState.Error(tokenException.localizedMessage ?: "Token exchange failed")
                    return@performTokenRequest
                }

                if (tokenResponse != null) {
                    tokenManager.saveTokens(
                        accessToken = tokenResponse.accessToken,
                        refreshToken = tokenResponse.refreshToken,
                        idToken = tokenResponse.idToken
                    )
                    _authState.value = AuthState.Authenticated("user@university.edu")
                } else {
                    _authState.value = AuthState.Error("Empty token response")
                }
            }
        } else {
            _authState.value = AuthState.Error("Invalid authentication response")
        }

    }

    fun loginWithMocks() {
        // Método de respaldo para mantener compatibilidad o pruebas directas
        _authState.value = AuthState.Loading
        tokenManager.saveTokens(
            accessToken = "mock_jwt_access_token",
            refreshToken = "mock_jwt_refresh_token",
            idToken = "mock_jwt_id_token"
        )
        _authState.value = AuthState.Authenticated("student@university.edu")
    }

    fun logout() {
        tokenManager.clearTokens()
        _authState.value = AuthState.Idle
    }
}
