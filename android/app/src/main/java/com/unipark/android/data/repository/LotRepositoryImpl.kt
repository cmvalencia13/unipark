package com.unipark.android.data.repository

import com.squareup.moshi.Moshi
import com.unipark.android.data.remote.api.LotApi
import com.unipark.android.data.remote.utils.safeApiCall
import com.unipark.android.domain.model.LotInfo
import com.unipark.android.domain.model.Resource
import com.unipark.android.domain.repository.LotRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class LotRepositoryImpl @Inject constructor(
    private val lotApi: LotApi,
    private val moshi: Moshi
) : LotRepository {

    // Diccionario estático de coordenadas para el canvas de cristal de la universidad
    private val lotCoordinateMapping = mapOf(
        "main" to Pair(0.5f, 0.35f),
        "west" to Pair(0.2f, 0.6f),
        "south" to Pair(0.75f, 0.7f)
    )

    override fun getLots(): Flow<Resource<List<LotInfo>>> = flow {
        emit(Resource.Loading)
        val result = safeApiCall(
            moshi = moshi,
            apiCall = { lotApi.getLots() },
            transform = { lotDtos ->
                lotDtos.map { dto ->
                    val coords = getCoordinatesForLot(dto.lotId, dto.name)
                    val occupancy = if (dto.capacityTotal > 0) {
                        (dto.capacityUsed * 100) / dto.capacityTotal
                    } else {
                        0
                    }
                    LotInfo(
                        id = dto.lotId,
                        name = dto.name,
                        occupancy = occupancy,
                        xFraction = coords.first,
                        yFraction = coords.second
                    )
                }
            }
        )
        emit(result)
    }.flowOn(Dispatchers.IO)

    override fun getLotDetails(id: String): Flow<Resource<LotInfo>> = flow {
        emit(Resource.Loading)
        val result = safeApiCall(
            moshi = moshi,
            apiCall = { lotApi.getLotDetails(id) },
            transform = { dto ->
                val coords = getCoordinatesForLot(dto.lotId, dto.name)
                val occupancy = if (dto.capacityTotal > 0) {
                    (dto.capacityUsed * 100) / dto.capacityTotal
                } else {
                    0
                }
                LotInfo(
                    id = dto.lotId,
                    name = dto.name,
                    occupancy = occupancy,
                    xFraction = coords.first,
                    yFraction = coords.second
                )
            }
        )
        emit(result)
    }.flowOn(Dispatchers.IO)

    // Resuelve coordenadas estáticas basadas en ID o Nombre del lote
    private fun getCoordinatesForLot(lotId: String, name: String): Pair<Float, Float> {
        val idLower = lotId.lowercase()
        val nameLower = name.lowercase()
        return when {
            idLower.contains("main") || nameLower.contains("main") -> Pair(0.5f, 0.35f)
            idLower.contains("west") || nameLower.contains("west") -> Pair(0.2f, 0.6f)
            idLower.contains("south") || nameLower.contains("south") -> Pair(0.75f, 0.7f)
            else -> lotCoordinateMapping[lotId] ?: Pair(0.5f, 0.5f)
        }
    }
}
