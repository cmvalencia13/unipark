package com.unipark.android.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface ScanDao {
    @Query("SELECT * FROM pending_scans WHERE synced = 0 ORDER BY scannedAt ASC")
    suspend fun getPendingScans(): List<PendingScanEntity>

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertPendingScan(scan: PendingScanEntity)

    @Query("UPDATE pending_scans SET synced = 1 WHERE idempotencyKey = :idempotencyKey")
    suspend fun markSynced(idempotencyKey: String)
}
