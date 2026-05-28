package com.unipark.android.domain.repository

import com.unipark.android.domain.model.LotInfo
import com.unipark.android.domain.model.Resource
import kotlinx.coroutines.flow.Flow

interface LotRepository {
    fun getLots(): Flow<Resource<List<LotInfo>>>
    fun getLotDetails(id: String): Flow<Resource<LotInfo>>
}
