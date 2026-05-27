package com.unipark.android.data.repositories

import com.unipark.android.core.network.OccupancyWebSocketClient
import com.unipark.android.data.remote.LotApiService
import com.unipark.android.data.remote.toDomain
import com.unipark.android.domain.entities.LotOccupancyUpdate
import com.unipark.android.domain.entities.ParkingLot
import com.unipark.android.domain.repositories.LotRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class LotRepositoryImpl @Inject constructor(
    private val lotApiService: LotApiService,
    private val occupancyWebSocketClient: OccupancyWebSocketClient,
) : LotRepository {
    override fun observeLots(): Flow<List<ParkingLot>> = flow {
        emit(getLots())
    }

    override fun observeOccupancyUpdates(): Flow<LotOccupancyUpdate> = occupancyWebSocketClient.observe()

    override suspend fun getLots(): List<ParkingLot> = runCatching {
        lotApiService.getLots().map { it.toDomain() }
    }.getOrElse {
        demoLots
    }

    override suspend fun getLot(lotId: UUID): ParkingLot = runCatching {
        lotApiService.getLot(lotId.toString()).toDomain()
    }.getOrElse {
        demoLots.firstOrNull { lot -> lot.id == lotId } ?: demoLots.first()
    }

    private val demoLots = listOf(
        ParkingLot(UUID(0, 1), "Lote A", capacityTotal = 120, capacityUsed = 62, active = true),
        ParkingLot(UUID(0, 2), "Lote B", capacityTotal = 80, capacityUsed = 66, active = true),
        ParkingLot(UUID(0, 3), "Lote C", capacityTotal = 45, capacityUsed = 45, active = true),
    )
}
