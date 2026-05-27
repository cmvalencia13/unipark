package com.unipark.android.data.repositories

import com.unipark.android.core.auth.OIDCAuthManager
import com.unipark.android.core.auth.TokenStorage
import com.unipark.android.domain.repositories.AuthRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepositoryImpl @Inject constructor(
    private val tokenStorage: TokenStorage,
    private val authManager: OIDCAuthManager,
) : AuthRepository {
    private val authenticated = MutableStateFlow(!tokenStorage.getAccessToken().isNullOrBlank())

    override val isAuthenticated: Flow<Boolean> = authenticated

    override suspend fun getAccessToken(): String? = tokenStorage.getAccessToken()

    override suspend fun refreshToken(): String? = authManager.refreshAccessToken().also {
        authenticated.value = !it.isNullOrBlank()
    }

    override suspend fun logout() {
        tokenStorage.clear()
        authenticated.value = false
    }
}
