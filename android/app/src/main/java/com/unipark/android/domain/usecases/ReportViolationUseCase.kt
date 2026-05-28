package com.unipark.android.domain.usecases

import com.unipark.android.domain.entities.Violation
import com.unipark.android.domain.repositories.ViolationRepository
import java.util.UUID
import javax.inject.Inject

class ReportViolationUseCase @Inject constructor(
    private val violationRepository: ViolationRepository,
) {
    suspend fun execute(
        vehicleId: UUID,
        lotId: UUID,
        reason: String,
        photoUri: String?,
    ): Violation = violationRepository.reportViolation(vehicleId, lotId, reason, photoUri)
}
