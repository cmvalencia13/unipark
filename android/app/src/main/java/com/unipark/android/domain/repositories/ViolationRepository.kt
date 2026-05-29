package com.unipark.android.domain.repositories

import com.unipark.android.domain.entities.Violation
import java.util.UUID

interface ViolationRepository {
    suspend fun reportViolation(
        vehicleId: UUID,
        lotId: UUID,
        reason: String,
        photoUri: String?,
    ): Violation
}
