package com.unipark.android.domain.entities

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.time.Instant
import java.util.UUID

@Parcelize
data class Violation(
    val id: UUID,
    val vehicleId: UUID,
    val lotId: UUID,
    val guardId: UUID,
    val reason: String,
    val photoUri: String?,
    val status: ViolationStatus,
    val createdAt: Instant,
) : Parcelable

enum class ViolationStatus { PENDING, APPROVED, DISMISSED }
