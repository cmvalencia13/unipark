package com.unipark.android.domain.repositories

import kotlinx.coroutines.flow.Flow

interface AuthRepository {
    val isAuthenticated: Flow<Boolean>
    suspend fun getAccessToken(): String?
    suspend fun refreshToken(): String?
    suspend fun logout()
}
