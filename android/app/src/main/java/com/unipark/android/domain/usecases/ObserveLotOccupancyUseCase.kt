package com.unipark.android.domain.usecases

import com.unipark.android.domain.entities.LotOccupancyUpdate
import com.unipark.android.domain.repositories.LotRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class ObserveLotOccupancyUseCase @Inject constructor(
    private val lotRepository: LotRepository,
) {
    fun execute(): Flow<LotOccupancyUpdate> = lotRepository.observeOccupancyUpdates()
}
