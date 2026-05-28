package com.unipark.android.data.remote.dto

import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class UserDto(
    @Json(name = "id") val id: String,
    @Json(name = "name") val name: String,
    @Json(name = "email") val email: String,
    @Json(name = "role") val role: String,
    @Json(name = "vehicles") val vehicles: List<VehicleDto>
)

@JsonClass(generateAdapter = true)
data class VehicleDto(
    @Json(name = "id") val id: String,
    @Json(name = "plateLast4") val plateLast4: String,
    @Json(name = "makeModel") val makeModel: String,
    @Json(name = "active") val active: Boolean
)
