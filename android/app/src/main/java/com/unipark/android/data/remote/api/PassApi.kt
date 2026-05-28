package com.unipark.android.data.remote.api

import com.unipark.android.data.remote.dto.PassResponseDto
import retrofit2.Response
import retrofit2.http.POST

interface PassApi {
    @POST("passes")
    suspend fun generatePass(): Response<PassResponseDto>
}
