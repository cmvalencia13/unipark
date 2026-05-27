package com.unipark.android.domain.repository

import com.unipark.android.domain.model.VehicleInfo
import com.unipark.android.domain.model.Resource
import kotlinx.coroutines.flow.Flow

interface UserRepository {
    fun getUserVehicles(): Flow<Resource<List<VehicleInfo>>>
}
