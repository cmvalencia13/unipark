package com.unipark.android.domain.repositories

import com.unipark.android.domain.entities.LotOccupancyUpdate
import com.unipark.android.domain.entities.ParkingLot
import kotlinx.coroutines.flow.Flow
import java.util.UUID

interface LotRepository {
    fun observeLots(): Flow<List<ParkingLot>>
    fun observeOccupancyUpdates(): Flow<LotOccupancyUpdate>
    suspend fun getLots(): List<ParkingLot>
    suspend fun getLot(lotId: UUID): ParkingLot
}
