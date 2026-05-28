package com.unipark.android.data.local

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(
    entities = [PendingScanEntity::class],
    version = 1,
    exportSchema = false,
)
abstract class UniParkDatabase : RoomDatabase() {
    abstract fun scanDao(): ScanDao
}
