package com.unipark.android.data.repository

import com.squareup.moshi.Moshi
import com.unipark.android.data.remote.api.UserApi
import com.unipark.android.data.remote.utils.safeApiCall
import com.unipark.android.domain.model.VehicleInfo
import com.unipark.android.domain.model.Resource
import com.unipark.android.domain.repository.UserRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class UserRepositoryImpl @Inject constructor(
    private val userApi: UserApi,
    private val moshi: Moshi
) : UserRepository {

    override fun getUserVehicles(): Flow<Resource<List<VehicleInfo>>> = flow {
        emit(Resource.Loading)
        val result = safeApiCall(
            moshi = moshi,
            apiCall = { userApi.getProfile() },
            transform = { userDto ->
                userDto.vehicles.map { dto ->
                    // Formatear plateLast4 para que se asemeje a una patente (ej: "*** 1234")
                    val formattedPlate = if (dto.plateLast4.length == 4) {
                        "*** ${dto.plateLast4}"
                    } else {
                        dto.plateLast4
                    }
                    VehicleInfo(
                        plate = formattedPlate,
                        makeModel = dto.makeModel,
                        isGuest = !dto.active,
                        validUntil = if (!dto.active) "Today, 6:00 PM" else null
                    )
                }
            }
        )
        emit(result)
    }.flowOn(Dispatchers.IO)
}
