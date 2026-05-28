package com.unipark.android.domain.repository

import com.unipark.android.domain.model.PermitInfo
import com.unipark.android.domain.model.Resource
import kotlinx.coroutines.flow.Flow

interface PassRepository {
    fun getActivePermits(): Flow<Resource<List<PermitInfo>>>
    fun generatePass(): Flow<Resource<PermitInfo>>
}
