package com.unipark.android.domain.usecases

import com.unipark.android.domain.entities.ParkingLot
import com.unipark.android.domain.repositories.LotRepository
import javax.inject.Inject

class GetLotsUseCase @Inject constructor(
    private val lotRepository: LotRepository,
) {
    suspend fun execute(): List<ParkingLot> = lotRepository.getLots()
}
