package com.unipark.android.data.remote

import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.Path

interface LotApiService {
    @GET("lots")
    suspend fun getLots(): List<LotDto>

    @GET("lots/{lotId}")
    suspend fun getLot(@Path("lotId") lotId: String): LotDto
}

interface PassApiService {
    @GET("passes/active")
    suspend fun getActivePass(): PassDto?

    @POST("passes")
    suspend fun generatePass(@Body request: GeneratePassRequestDto): PassDto
}

interface ScanApiService {
    @POST("scans")
    suspend fun submitScan(
        @Header("Idempotency-Key") key: String,
        @Body scan: ScanRequestDto,
    ): ScanResponseDto
}

interface ViolationApiService {
    @POST("violations")
    suspend fun reportViolation(@Body violation: ViolationRequestDto): ViolationDto
}
