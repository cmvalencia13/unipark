package com.unipark.android.domain.usecases

import com.unipark.android.domain.entities.Scan
import com.unipark.android.domain.entities.ScanDirection
import com.unipark.android.domain.repositories.ScanRepository
import java.util.UUID
import javax.inject.Inject

class ScanQRUseCase @Inject constructor(
    private val scanRepository: ScanRepository,
) {
    suspend fun execute(
        qrPayload: String,
        direction: ScanDirection,
        lotId: UUID,
    ): Scan = scanRepository.submitScan(qrPayload, direction, lotId)
}
