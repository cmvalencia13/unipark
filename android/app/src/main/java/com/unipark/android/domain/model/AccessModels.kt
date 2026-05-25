package com.unipark.android.domain.model

enum class ScannerState {
    IDLE, SCANNING, SUCCESS, ERROR
}

data class AuthorizedVehicle(
    val plate: String,
    val destinationLot: String,
)
