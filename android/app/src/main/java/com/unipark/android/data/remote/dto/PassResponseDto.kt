package com.unipark.android.data.remote.dto

import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class PassResponseDto(
    @Json(name = "passId") val passId: String,
    @Json(name = "payload") val payload: String,
    @Json(name = "signature") val signature: String,
    @Json(name = "expiresAt") val expiresAt: String
)
