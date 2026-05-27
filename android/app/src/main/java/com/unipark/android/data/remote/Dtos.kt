package com.unipark.android.data.remote

import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class UserDto(
    val id: String,
    val email: String,
    @Json(name = "full_name") val fullName: String,
    val role: String,
    val active: Boolean,
)

@JsonClass(generateAdapter = true)
data class VehicleDto(
    val id: String,
    @Json(name = "owner_id") val ownerId: String,
    val plate: String,
    val make: String,
    val model: String,
    val color: String,
    val active: Boolean,
)

@JsonClass(generateAdapter = true)
data class LotDto(
    val id: String,
    val name: String,
    @Json(name = "capacity_total") val capacityTotal: Int,
    @Json(name = "capacity_used") val capacityUsed: Int,
    val active: Boolean,
)

@JsonClass(generateAdapter = true)
data class PassDto(
    val id: String,
    @Json(name = "user_id") val userId: String,
    @Json(name = "vehicle_id") val vehicleId: String,
    @Json(name = "lot_id") val lotId: String?,
    val payload: String,
    val signature: String,
    @Json(name = "expires_at") val expiresAt: String,
    val active: Boolean,
)

@JsonClass(generateAdapter = true)
data class GeneratePassRequestDto(
    @Json(name = "vehicle_id") val vehicleId: String,
)

@JsonClass(generateAdapter = true)
data class ScanRequestDto(
    @Json(name = "pass_payload") val passPayload: String,
    @Json(name = "pass_signature") val passSignature: String,
    val direction: String,
    @Json(name = "lot_id") val lotId: String,
)

@JsonClass(generateAdapter = true)
data class ScanResponseDto(
    val id: String,
    @Json(name = "pass_id") val passId: String,
    @Json(name = "lot_id") val lotId: String,
    @Json(name = "guard_id") val guardId: String,
    val direction: String,
    val status: String,
    @Json(name = "scanned_at") val scannedAt: String,
)

@JsonClass(generateAdapter = true)
data class ViolationRequestDto(
    @Json(name = "vehicle_id") val vehicleId: String,
    @Json(name = "lot_id") val lotId: String,
    val reason: String,
    @Json(name = "photo_uri") val photoUri: String?,
)

@JsonClass(generateAdapter = true)
data class ViolationDto(
    val id: String,
    @Json(name = "vehicle_id") val vehicleId: String,
    @Json(name = "lot_id") val lotId: String,
    @Json(name = "guard_id") val guardId: String,
    val reason: String,
    @Json(name = "photo_uri") val photoUri: String?,
    val status: String,
    @Json(name = "created_at") val createdAt: String,
)

@JsonClass(generateAdapter = true)
data class LotOccupancyUpdateDto(
    @Json(name = "lot_id") val lotId: String,
    @Json(name = "capacity_used") val capacityUsed: Int,
    @Json(name = "capacity_total") val capacityTotal: Int,
)
