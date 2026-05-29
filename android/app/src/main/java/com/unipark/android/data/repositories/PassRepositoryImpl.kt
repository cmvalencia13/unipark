package com.unipark.android.data.repositories

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
    // El backend GET /passes/active auto-crea un pase de 12h si no hay uno activo,
    // y es la única fuente del qrPayload firmado, así que ambas rutas la usan.
    override suspend fun generatePass(vehicleId: UUID): Pass = getActivePass() ?: demoPass()

    override suspend fun getActivePass(): Pass? = runCatching {
        passApiService.getActivePass()?.toDomain()
    }.getOrNull()

    private fun demoPass() = Pass(
        id = UUID.randomUUID(),
        qrPayload = "demo-nonce:demo-signature",
        expiresAt = Instant.now().plusSeconds(60),
    )
}
