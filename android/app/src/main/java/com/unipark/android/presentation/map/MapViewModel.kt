package com.unipark.android.presentation.map

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.unipark.android.domain.entities.ParkingLot
import com.unipark.android.domain.model.LotInfo
import com.unipark.android.domain.model.Resource
import com.unipark.android.domain.repositories.LotRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MapViewModel @Inject constructor(
    private val lotRepository: LotRepository
) : ViewModel() {

    private val _lotsState = MutableStateFlow<Resource<List<LotInfo>>>(Resource.Loading)
    val lotsState: StateFlow<Resource<List<LotInfo>>> = _lotsState.asStateFlow()

    private val _lots = MutableStateFlow<List<LotInfo>>(emptyList())
    val lots: StateFlow<List<LotInfo>> = _lots.asStateFlow()

    private val _selectedLot = MutableStateFlow<LotInfo?>(null)
    val selectedLot: StateFlow<LotInfo?> = _selectedLot.asStateFlow()

    private val _filters = MutableStateFlow(fakeFilters)
    val filters: StateFlow<List<String>> = _filters.asStateFlow()

    init {
        fetchLots()
    }

    fun fetchLots() {
        viewModelScope.launch {
            _lotsState.value = Resource.Loading
            runCatching { lotRepository.getLots() }
                .onSuccess { lots ->
                    val mapped = lots.mapIndexed { index, lot -> lot.toLotInfo(index) }
                    val result = mapped.ifEmpty { fakeLots }
                    _lots.value = result
                    _lotsState.value = Resource.Success(result)
                }
                .onFailure { e ->
                    // Caída de gracia a mocks para evitar pantalla vacía/bloqueo de carga en desarrollo local
                    _lots.value = fakeLots
                    _lotsState.value = Resource.Error(e.message ?: "Error al cargar lotes")
                }
        }
    }

    fun selectLot(lot: LotInfo) {
        _selectedLot.value = lot
    }

    fun dismissSheet() {
        _selectedLot.value = null
    }

    // El backend no expone coordenadas; se asignan posiciones de demo deterministas por índice.
    private fun ParkingLot.toLotInfo(index: Int): LotInfo {
        val position = demoPositions[index % demoPositions.size]
        return LotInfo(
            id = id.toString(),
            name = name,
            occupancy = (occupancyPercentage * 100).toInt(),
            xFraction = position.first,
            yFraction = position.second,
        )
    }

    companion object {
        private val demoPositions = listOf(
            0.5f to 0.35f,
            0.2f to 0.6f,
            0.75f to 0.7f,
            0.35f to 0.5f,
            0.6f to 0.25f,
        )

        val fakeLots = listOf(
            LotInfo(
                id = "main",
                name = "Main Campus Garage",
                occupancy = 72,
                xFraction = 0.5f,
                yFraction = 0.35f,
            ),
            LotInfo(
                id = "west",
                name = "West Lot",
                occupancy = 91,
                xFraction = 0.2f,
                yFraction = 0.6f,
            ),
            LotInfo(
                id = "south",
                name = "South Deck",
                occupancy = 45,
                xFraction = 0.75f,
                yFraction = 0.7f,
            ),
        )

        val fakeFilters = listOf(
            "EV Charging",
            "ADA Spots",
            "Faculty Only",
            "Visitor",
        )
    }
}
