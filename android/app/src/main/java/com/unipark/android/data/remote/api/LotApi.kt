package com.unipark.android.data.remote.api

import com.unipark.android.data.remote.dto.LotDto
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Path

interface LotApi {
    @GET("lots")
    suspend fun getLots(): Response<List<LotDto>>

    @GET("lots/{id}")
    suspend fun getLotDetails(@Path("id") lotId: String): Response<LotDto>
}
