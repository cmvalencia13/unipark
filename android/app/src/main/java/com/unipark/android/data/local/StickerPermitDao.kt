package com.unipark.android.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface StickerPermitDao {
    @Query("SELECT * FROM sticker_permits WHERE userId = :userId LIMIT 1")
    suspend fun getStickerPermit(userId: String): StickerPermitEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertStickerPermit(stickerPermit: StickerPermitEntity)
}
