package com.unipark.android.data.local

import android.content.Context
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ScanSyncScheduler @Inject constructor(
    @ApplicationContext private val context: Context,
) {
    fun enqueue() {
        val request = OneTimeWorkRequestBuilder<ScanSyncWorker>()
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build(),
            )
            .build()

        WorkManager.getInstance(context).enqueueUniqueWork(
            "pending-scan-sync",
            ExistingWorkPolicy.KEEP,
            request,
        )
    }
}
