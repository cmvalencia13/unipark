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
    val lastResult: Scan? = null,
    val error: String? = null,
    val processing: Boolean = false,
    val actionsEnabled: Boolean = true,
)

@HiltViewModel
class ScannerViewModel @Inject constructor(
    private val scanQRUseCase: ScanQRUseCase,
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
            _state.value = _state.value.copy(error = "QR invalido")
            return
        }

        viewModelScope.launch {
            _state.value = _state.value.copy(processing = true, actionsEnabled = false, error = null)
            runCatching {
                scanQRUseCase.execute(payload, signature, _state.value.direction, _state.value.selectedLotId)
            }
                .onSuccess { _state.value = _state.value.copy(lastResult = it, processing = false) }
                .onFailure { _state.value = _state.value.copy(error = it.message, processing = false) }
            delay(2_000)
            _state.value = _state.value.copy(actionsEnabled = true)
        }
    }
}
