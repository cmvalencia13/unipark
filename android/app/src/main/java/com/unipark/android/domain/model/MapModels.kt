package com.unipark.android.domain.model

data class LotInfo(
    val id: String,
    val name: String,
    val occupancy: Int,
    val xFraction: Float,
    val yFraction: Float,
)
