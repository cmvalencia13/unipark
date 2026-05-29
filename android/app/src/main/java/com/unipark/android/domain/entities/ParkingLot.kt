package com.unipark.android.domain.entities

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.util.UUID

@Parcelize
data class ParkingLot(
    val id: UUID,
    val name: String,
    val capacityTotal: Int,
    val capacityUsed: Int,
    val active: Boolean,
) : Parcelable {
    val availableSpots: Int get() = capacityTotal - capacityUsed
    val occupancyPercentage: Double get() = if (capacityTotal == 0) 0.0 else capacityUsed.toDouble() / capacityTotal
    val isFull: Boolean get() = capacityUsed >= capacityTotal
}
