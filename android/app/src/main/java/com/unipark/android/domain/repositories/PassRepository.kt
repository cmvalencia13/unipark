package com.unipark.android.domain.repositories

import com.unipark.android.domain.entities.Pass
import java.util.UUID

interface PassRepository {
    suspend fun generatePass(vehicleId: UUID): Pass
    suspend fun getActivePass(): Pass?
}
