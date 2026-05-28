package com.unipark.android.data.repositories

import com.unipark.android.data.remote.GeneratePassRequestDto
import com.unipark.android.data.remote.PassApiService
import com.unipark.android.data.remote.toDomain
import com.unipark.android.domain.entities.Pass
import com.unipark.android.domain.repositories.PassRepository
import java.time.Instant
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PassRepositoryImpl @Inject constructor(
    private val passApiService: PassApiService,
) : PassRepository {
    override suspend fun generatePass(vehicleId: UUID): Pass =
        runCatching {
            passApiService.generatePass(GeneratePassRequestDto(vehicleId.toString())).toDomain()
        }.getOrElse {
            demoPass(vehicleId)
        }

    override suspend fun getActivePass(): Pass? = runCatching {
        passApiService.getActivePass()?.toDomain()
    }.getOrNull()

    private fun demoPass(vehicleId: UUID) = Pass(
        id = UUID.randomUUID(),
        userId = UUID(0, 10),
        vehicleId = vehicleId,
        lotId = UUID(0, 1),
        payload = "demo-pass-${UUID.randomUUID()}",
        signature = "demo-signature",
        expiresAt = Instant.now().plusSeconds(60),
        active = true,
    )
}
