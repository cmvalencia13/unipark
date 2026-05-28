package com.unipark.android.data.remote.dto

import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class LotDto(
    @Json(name = "lotId") val lotId: String,
    @Json(name = "name") val name: String,
    @Json(name = "capacityTotal") val capacityTotal: Int,
    @Json(name = "capacityUsed") val capacityUsed: Int,
    @Json(name = "geo") val geo: String?
)
