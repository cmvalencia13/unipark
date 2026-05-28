package com.unipark.android.data.repositories

import com.unipark.android.data.remote.ViolationApiService
import com.unipark.android.data.remote.ViolationRequestDto
import com.unipark.android.data.remote.toDomain
import com.unipark.android.domain.entities.Violation
import com.unipark.android.domain.entities.ViolationStatus
import com.unipark.android.domain.repositories.ViolationRepository
import java.time.Instant
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ViolationRepositoryImpl @Inject constructor(
    private val violationApiService: ViolationApiService,
) : ViolationRepository {
    override suspend fun reportViolation(
        vehicleId: UUID,
        lotId: UUID,
        reason: String,
        photoUri: String?,
    ): Violation = runCatching {
        violationApiService.reportViolation(
            ViolationRequestDto(
                vehicleId = vehicleId.toString(),
                lotId = lotId.toString(),
                reason = reason,
                photoUri = photoUri,
            ),
        ).toDomain()
    }.getOrElse {
        Violation(
            id = UUID.randomUUID(),
            vehicleId = vehicleId,
            lotId = lotId,
            guardId = UUID(0, 20),
            reason = reason,
            photoUri = photoUri,
            status = ViolationStatus.PENDING,
            createdAt = Instant.now(),
        )
    }
}
