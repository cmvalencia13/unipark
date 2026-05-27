package com.unipark.android.presentation.auth

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

sealed interface AuthState {
    data object Idle : AuthState
    data object Loading : AuthState
    data class Authenticated(val email: String, val role: AppRole) : AuthState
    data class Error(val message: String) : AuthState
}

enum class AppRole { DRIVER, SECURITY_GUARD }

@HiltViewModel
class AuthViewModel @Inject constructor() : ViewModel() {
    private val _authState = MutableStateFlow<AuthState>(AuthState.Idle)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    fun login(email: String, role: AppRole) {
        _authState.value = AuthState.Loading
        _authState.value = AuthState.Authenticated(email, role)
    }

    fun logout() {
        _authState.value = AuthState.Idle
    }
}
