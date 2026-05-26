package com.unipark.android.domain.model

data class PermitInfo(
    val permitName: String,
    val status: String,
    val validUntil: String,
    val vehiclePlate: String,
)

data class LocationInfo(
    val lotName: String,
    val spotNumber: String,
    val parkedSince: String,
)

data class OccupancyData(
    val lotName: String,
    val percentage: Int,
)

data class AlertItem(
    val title: String,
    val body: String,
    val timestamp: String,
    val type: AlertType,
)

enum class AlertType {
    Info,
    Warning,
    Maintenance,
}
