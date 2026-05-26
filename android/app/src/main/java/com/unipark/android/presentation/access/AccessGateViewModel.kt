package com.unipark.android.presentation.access

import androidx.lifecycle.ViewModel
import com.unipark.android.domain.model.AuthorizedVehicle
import com.unipark.android.domain.model.ScannerState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class AccessGateViewModel @Inject constructor() : ViewModel() {

    private val _scannerState = MutableStateFlow(ScannerState.IDLE)
    val scannerState: StateFlow<ScannerState> = _scannerState.asStateFlow()

    private val _authorizedVehicle = MutableStateFlow(fakeVehicle)
    val authorizedVehicle: StateFlow<AuthorizedVehicle> = _authorizedVehicle.asStateFlow()

    private val _systemReady = MutableStateFlow(true)
    val systemReady: StateFlow<Boolean> = _systemReady.asStateFlow()

    fun startScan() {
        _scannerState.value = ScannerState.SCANNING
    }

    fun completeScan(success: Boolean) {
        _scannerState.value = if (success) ScannerState.SUCCESS else ScannerState.ERROR
    }

    fun resetScanner() {
        _scannerState.value = ScannerState.IDLE
    }

    companion object {
        val fakeVehicle = AuthorizedVehicle(
            plate = "ABC-1234",
            destinationLot = "Main Campus Garage",
        )
    }
}
