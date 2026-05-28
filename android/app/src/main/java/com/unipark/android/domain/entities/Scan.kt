package com.unipark.android.domain.entities

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.time.Instant
import java.util.UUID

@Parcelize
data class Scan(
    val id: UUID,
    val passId: UUID,
    val lotId: UUID,
    val guardId: UUID,
    val direction: ScanDirection,
    val status: ScanStatus,
    val scannedAt: Instant,
) : Parcelable

enum class ScanDirection { ENTRY, EXIT }

enum class ScanStatus { ACCEPTED, REJECTED, OFFLINE_PENDING }
