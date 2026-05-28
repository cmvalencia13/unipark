package com.unipark.android.presentation.map

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.unipark.android.domain.model.LotInfo
import com.unipark.android.domain.model.Resource
import com.unipark.android.domain.repository.LotRepository
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
            lotRepository.getLots().collect { resource ->
                _lotsState.value = resource
                when (resource) {
                    is Resource.Success -> {
                        _lots.value = resource.data
                    }
                    is Resource.Error -> {
                        // Caída de gracia a mocks para evitar pantalla vacía/bloqueo de carga en desarrollo local
                        _lots.value = fakeLots
                    }
                    is Resource.Loading -> {
                        // Se mantiene cargando
                    }
                }
            }
        }
    }

    fun selectLot(lot: LotInfo) {
        _selectedLot.value = lot
    }

    fun dismissSheet() {
        _selectedLot.value = null
    }

    companion object {
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
