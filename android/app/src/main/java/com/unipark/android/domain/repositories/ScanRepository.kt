package com.unipark.android.domain.repositories

import com.unipark.android.domain.entities.Scan
import com.unipark.android.domain.entities.ScanDirection
import java.util.UUID

interface ScanRepository {
    suspend fun submitScan(
        passPayload: String,
        passSignature: String,
        direction: ScanDirection,
        lotId: UUID,
    ): Scan

    suspend fun syncPendingScans()
}
