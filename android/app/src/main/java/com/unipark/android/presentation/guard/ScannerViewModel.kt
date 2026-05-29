package com.unipark.android.presentation.guard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.unipark.android.domain.entities.Scan
import com.unipark.android.domain.entities.ScanDirection
import com.unipark.android.domain.usecases.ScanQRUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.delay
import java.util.UUID
import javax.inject.Inject

data class ScannerState(
    val direction: ScanDirection = ScanDirection.ENTRY,
    val selectedLotId: UUID = UUID(0, 1),
    val selectedLotName: String = "Lote A",
    val lastResult: GuardScanResult? = null,
    val error: String? = null,
    val processing: Boolean = false,
    val actionsEnabled: Boolean = true,
)

@HiltViewModel
class ScannerViewModel @Inject constructor(
    private val scanQRUseCase: ScanQRUseCase,
    private val guardStateStore: GuardStateStore,
) : ViewModel() {
    private val _state = MutableStateFlow(ScannerState())
    val state: StateFlow<ScannerState> = _state.asStateFlow()

    fun setDirection(direction: ScanDirection) {
        _state.value = _state.value.copy(direction = direction)
    }

    fun selectLot(name: String) {
        val lotId = when (name) {
            "Lote B" -> UUID(0, 2)
            "Lote C" -> UUID(0, 3)
            else -> UUID(0, 1)
        }
        _state.value = _state.value.copy(selectedLotName = name, selectedLotId = lotId)
    }

    fun onQRDetected(qrContent: String) {
        if (_state.value.processing || !_state.value.actionsEnabled) return
        val parts = qrContent.split(".", limit = 2)
        val payload = parts.getOrNull(0).orEmpty()
        val signature = parts.getOrNull(1).orEmpty()
        if (payload.isBlank() || signature.isBlank()) {
            _state.value = _state.value.copy(error = "QR invalido: usa el pase digital de UniPark")
            return
        }

        if (payload.startsWith("unipark-pass:") && signature == "demo-signature") {
            applyLocalDemoScan()
            return
        }

        viewModelScope.launch {
            _state.value = _state.value.copy(processing = true, actionsEnabled = false, error = null)
            runCatching {
                scanQRUseCase.execute(payload, signature, _state.value.direction, _state.value.selectedLotId)
            }
                .onSuccess {
                    val result = guardStateStore.applyScan(
                        lotId = _state.value.selectedLotId,
                        lotName = _state.value.selectedLotName,
                        direction = _state.value.direction,
                    )
                    _state.value = _state.value.copy(lastResult = result, processing = false)
                }
                .onFailure {
                    val pending = GuardScanResult(
                        lotName = _state.value.selectedLotName,
                        direction = _state.value.direction,
                        status = com.unipark.android.domain.entities.ScanStatus.OFFLINE_PENDING,
                        message = "Pendiente por conexion",
                        scannedAt = java.time.Instant.now(),
                    )
                    _state.value = _state.value.copy(lastResult = pending, error = it.message, processing = false)
                }
            delay(2_000)
            _state.value = _state.value.copy(actionsEnabled = true)
        }
    }

    fun simulateScan() {
        if (_state.value.processing || !_state.value.actionsEnabled) return
        applyLocalDemoScan()
    }

    private fun applyLocalDemoScan() {
        viewModelScope.launch {
            _state.value = _state.value.copy(processing = true, actionsEnabled = false, error = null)
            val result = guardStateStore.applyScan(
                lotId = _state.value.selectedLotId,
                lotName = _state.value.selectedLotName,
                direction = _state.value.direction,
            )
            _state.value = _state.value.copy(lastResult = result, processing = false)
            delay(2_000)
            _state.value = _state.value.copy(actionsEnabled = true)
        }
    }
}
