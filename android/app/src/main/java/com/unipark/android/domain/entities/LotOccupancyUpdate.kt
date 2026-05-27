package com.unipark.android.domain.entities

import java.util.UUID

data class LotOccupancyUpdate(
    val lotId: UUID,
    val capacityUsed: Int,
    val capacityTotal: Int,
)
