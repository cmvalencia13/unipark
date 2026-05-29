package com.unipark.android.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.unipark.android.data.remote.ScanRequestDto

@Entity(tableName = "pending_scans")
data class PendingScanEntity(
    @PrimaryKey val idempotencyKey: String,
    val qrPayload: String,
    val direction: String,
    val lotId: String,
    val scannedAt: Long,
    val synced: Boolean = false,
) {
    fun toDto() = ScanRequestDto(
        qrPayload = qrPayload,
        direction = direction,
        lotId = lotId,
    )
}
