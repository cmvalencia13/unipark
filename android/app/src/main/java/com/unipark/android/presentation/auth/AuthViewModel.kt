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
import net.openid.appauth.AuthorizationException
import net.openid.appauth.AuthorizationRequest
import net.openid.appauth.AuthorizationResponse
import net.openid.appauth.AuthorizationService
import net.openid.appauth.AuthorizationServiceConfiguration
import net.openid.appauth.ResponseTypeValues
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
    private val tokenManager: TokenManager,
) : ViewModel() {
    private val _authState = MutableStateFlow<AuthState>(AuthState.Idle)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    private var pendingRole: AppRole = AppRole.DRIVER

    private val authServiceConfiguration = AuthorizationServiceConfiguration(
        Uri.parse("http://10.0.2.2:8082/realms/unipark/protocol/openid-connect/auth"),
        Uri.parse("http://10.0.2.2:8082/realms/unipark/protocol/openid-connect/token"),
    )

    init {
        val token = tokenManager.getAccessToken()
        if (!token.isNullOrBlank()) {
            _authState.value = AuthState.Authenticated("user@university.edu", AppRole.DRIVER)
        }
    }

    fun getAuthIntent(context: Context, role: AppRole): Intent {
        pendingRole = role
        val authRequest = AuthorizationRequest.Builder(
            authServiceConfiguration,
            "unipark-mobile",
            ResponseTypeValues.CODE,
            Uri.parse("com.unipark.app://callback"),
        ).setScope("openid profile email offline_access")
            .build()

        val authService = AuthorizationService(context)
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

        if (response == null) {
            _authState.value = AuthState.Error("Invalid authentication response")
            return
        }

        val authService = AuthorizationService(context)
        authService.performTokenRequest(response.createTokenExchangeRequest()) { tokenResponse, tokenException ->
            authService.dispose()
            when {
                tokenException != null -> {
                    _authState.value = AuthState.Error(tokenException.localizedMessage ?: "Token exchange failed")
                }

                tokenResponse != null -> {
                    tokenManager.saveTokens(
                        accessToken = tokenResponse.accessToken,
                        refreshToken = tokenResponse.refreshToken,
                        idToken = tokenResponse.idToken,
                    )
                    _authState.value = AuthState.Authenticated("user@university.edu", pendingRole)
                }

                else -> {
                    _authState.value = AuthState.Error("Empty token response")
                }
            }
        }
    }

    fun login(email: String, role: AppRole) {
        _authState.value = AuthState.Loading
        tokenManager.saveTokens(
            accessToken = "mock_jwt_access_token",
            refreshToken = "mock_jwt_refresh_token",
            idToken = "mock_jwt_id_token",
        )
        _authState.value = AuthState.Authenticated(email, role)
    }

    fun loginWithMocks(role: AppRole = AppRole.DRIVER) {
        login("student@university.edu", role)
    }

    fun logout() {
        tokenManager.clearTokens()
        _authState.value = AuthState.Idle
    }
}
