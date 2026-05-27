package com.unipark.android.data.repository

import com.squareup.moshi.Moshi
import com.unipark.android.data.remote.api.PassApi
import com.unipark.android.data.remote.utils.safeApiCall
import com.unipark.android.domain.model.PermitInfo
import com.unipark.android.domain.model.Resource
import com.unipark.android.domain.repository.PassRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PassRepositoryImpl @Inject constructor(
    private val passApi: PassApi,
    private val moshi: Moshi
) : PassRepository {

    override fun getActivePermits(): Flow<Resource<List<PermitInfo>>> = flow {
        emit(Resource.Loading)
        val result = safeApiCall(
            moshi = moshi,
            apiCall = { passApi.generatePass() },
            transform = { dto ->
                listOf(
                    PermitInfo(
                        permitName = "Semester Parking",
                        status = "Active",
                        validUntil = formatIsoDate(dto.expiresAt),
                        vehiclePlate = "ABC 1234"
                    )
                )
            }
        )
        emit(result)
    }.flowOn(Dispatchers.IO)

    override fun generatePass(): Flow<Resource<PermitInfo>> = flow {
        emit(Resource.Loading)
        val result = safeApiCall(
            moshi = moshi,
            apiCall = { passApi.generatePass() },
            transform = { dto ->
                PermitInfo(
                    permitName = "Semester Parking",
                    status = "Active",
                    validUntil = formatIsoDate(dto.expiresAt),
                    vehiclePlate = "ABC 1234"
                )
            }
        )
        emit(result)
    }.flowOn(Dispatchers.IO)

    private fun formatIsoDate(isoString: String): String {
        return try {
            val parser = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault()).apply {
                timeZone = TimeZone.getTimeZone("UTC")
            }
            val formatter = SimpleDateFormat("MMM dd, yyyy - hh:mm a", Locale.getDefault())
            val date = parser.parse(isoString)
            if (date != null) formatter.format(date) else isoString
        } catch (e: Exception) {
            isoString
        }
    }
}
