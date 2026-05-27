package com.unipark.android.presentation.driver

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.unipark.android.domain.entities.ParkingLot
import com.unipark.android.domain.usecases.GetLotsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class DriverDashboardState(
    val greeting: String = "Hola, driver",
    val lots: List<ParkingLot> = emptyList(),
    val loading: Boolean = true,
    val error: String? = null,
)

@HiltViewModel
class DriverDashboardViewModel @Inject constructor(
    private val getLotsUseCase: GetLotsUseCase,
) : ViewModel() {
    private val _state = MutableStateFlow(DriverDashboardState())
    val state: StateFlow<DriverDashboardState> = _state.asStateFlow()

    init {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            _state.value = _state.value.copy(loading = true, error = null)
            runCatching { getLotsUseCase.execute() }
                .onSuccess { _state.value = DriverDashboardState(lots = it, loading = false) }
                .onFailure { _state.value = DriverDashboardState(loading = false, error = it.message) }
        }
    }
}
