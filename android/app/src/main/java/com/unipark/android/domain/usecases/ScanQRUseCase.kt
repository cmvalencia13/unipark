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
        passPayload: String,
        passSignature: String,
        direction: ScanDirection,
        lotId: UUID,
    ): Scan = scanRepository.submitScan(passPayload, passSignature, direction, lotId)
}
