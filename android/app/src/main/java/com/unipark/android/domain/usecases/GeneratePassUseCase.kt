package com.unipark.android.domain.usecases

import com.unipark.android.domain.entities.Pass
import com.unipark.android.domain.repositories.PassRepository
import java.util.UUID
import javax.inject.Inject

class GeneratePassUseCase @Inject constructor(
    private val passRepository: PassRepository,
) {
    suspend fun execute(vehicleId: UUID): Pass = passRepository.generatePass(vehicleId)
}
