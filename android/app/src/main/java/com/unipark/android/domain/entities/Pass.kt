package com.unipark.android.domain.entities

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.time.Instant
import java.util.UUID

@Parcelize
data class Pass(
    val id: UUID,
    val userId: UUID,
    val vehicleId: UUID,
    val lotId: UUID?,
    val payload: String,
    val signature: String,
    val expiresAt: Instant,
    val active: Boolean,
) : Parcelable {
    val isExpired: Boolean get() = Instant.now().isAfter(expiresAt)
}
