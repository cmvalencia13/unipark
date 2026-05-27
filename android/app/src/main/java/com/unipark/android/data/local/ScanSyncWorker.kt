package com.unipark.android.data.local

import android.content.Context
import androidx.hilt.work.HiltWorker
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.unipark.android.data.remote.ScanApiService
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject

@HiltWorker
class ScanSyncWorker @AssistedInject constructor(
    @Assisted context: Context,
    @Assisted params: WorkerParameters,
    private val scanDao: ScanDao,
    private val apiService: ScanApiService,
) : CoroutineWorker(context, params) {
    override suspend fun doWork(): Result {
        val pending = scanDao.getPendingScans()
        pending.forEach { scan ->
            try {
                apiService.submitScan(scan.idempotencyKey, scan.toDto())
                scanDao.markSynced(scan.idempotencyKey)
            } catch (_: Exception) {
                return Result.retry()
            }
        }
        return Result.success()
    }
}
