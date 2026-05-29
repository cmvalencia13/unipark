package com.unipark.android.data.repositories

import com.unipark.android.data.local.PendingScanEntity
import com.unipark.android.data.local.ScanDao
import com.unipark.android.data.local.ScanSyncScheduler
import com.unipark.android.data.remote.ScanApiService
import com.unipark.android.data.remote.ScanRequestDto
import com.unipark.android.data.remote.toDomain
import com.unipark.android.domain.entities.Scan
import com.unipark.android.domain.entities.ScanDirection
import com.unipark.android.domain.entities.ScanStatus
import com.unipark.android.domain.repositories.ScanRepository
import java.time.Instant
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ScanRepositoryImpl @Inject constructor(
    private val scanApiService: ScanApiService,
    private val scanDao: ScanDao,
    private val scanSyncScheduler: ScanSyncScheduler,
) : ScanRepository {
    override suspend fun submitScan(
        passPayload: String,
        passSignature: String,
        direction: ScanDirection,
        lotId: UUID,
    ): Scan {
        val idempotencyKey = UUID.randomUUID().toString()
        return try {
            scanApiService.submitScan(
                key = idempotencyKey,
                scan = ScanRequestDto(
                    passPayload = passPayload,
                    passSignature = passSignature,
                    direction = direction.name,
                    lotId = lotId.toString(),
                ),
            ).toDomain()
        } catch (_: Exception) {
            scanDao.insertPendingScan(
                PendingScanEntity(
                    idempotencyKey = idempotencyKey,
                    passPayload = passPayload,
                    passSignature = passSignature,
                    direction = direction.name,
                    lotId = lotId.toString(),
                    scannedAt = Instant.now().toEpochMilli(),
                ),
            )
            scanSyncScheduler.enqueue()
            Scan(
                id = UUID.randomUUID(),
                passId = UUID.nameUUIDFromBytes(passPayload.toByteArray()),
                lotId = lotId,
                guardId = UUID(0, 0),
                direction = direction,
                status = ScanStatus.OFFLINE_PENDING,
                scannedAt = Instant.now(),
            )
        }
    }

    override suspend fun syncPendingScans() {
        scanDao.getPendingScans().forEach { pending ->
            scanApiService.submitScan(pending.idempotencyKey, pending.toDto())
            scanDao.markSynced(pending.idempotencyKey)
        }
    }
}
