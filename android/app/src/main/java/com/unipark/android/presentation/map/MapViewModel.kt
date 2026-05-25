package com.unipark.android.presentation.map

import androidx.lifecycle.ViewModel
import com.unipark.android.domain.model.LotInfo
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class MapViewModel @Inject constructor() : ViewModel() {

    private val _lots = MutableStateFlow(fakeLots)
    val lots: StateFlow<List<LotInfo>> = _lots.asStateFlow()

    private val _selectedLot = MutableStateFlow<LotInfo?>(null)
    val selectedLot: StateFlow<LotInfo?> = _selectedLot.asStateFlow()

    private val _filters = MutableStateFlow(fakeFilters)
    val filters: StateFlow<List<String>> = _filters.asStateFlow()

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
