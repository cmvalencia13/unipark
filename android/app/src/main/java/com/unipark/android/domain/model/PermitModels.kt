package com.unipark.android.domain.model

data class VehicleInfo(
    val plate: String,
    val makeModel: String,
    val isGuest: Boolean = false,
    val validUntil: String? = null,
)

data class PricingOption(
    val name: String,
    val price: String,
    val description: String,
    val highlight: Boolean = false,
)
