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
            lotRepository.getLots().collect { resource ->
                if (resource is Resource.Success) {
                    _lots.value = resource.data
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
        val fakeFilters = listOf(
            "EV Charging",
            "ADA Spots",
            "Faculty Only",
            "Visitor",
        )
    }
}
