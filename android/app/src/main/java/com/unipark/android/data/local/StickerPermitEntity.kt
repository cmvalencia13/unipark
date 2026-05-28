package com.unipark.android.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.unipark.android.ui.driver.StickerPermit
import java.time.Instant
import java.util.UUID

@Entity(tableName = "sticker_permits")
data class StickerPermitEntity(
    @PrimaryKey val userId: String,
    val qrContent: String,
    val savedAt: Long,
) {
    fun toUiModel() = StickerPermit(
        userId = UUID.fromString(userId),
        qrContent = qrContent,
        savedAt = Instant.ofEpochMilli(savedAt),
    )
}

fun StickerPermit.toEntity() = StickerPermitEntity(
    userId = userId.toString(),
    qrContent = qrContent,
    savedAt = savedAt.toEpochMilli(),
)
