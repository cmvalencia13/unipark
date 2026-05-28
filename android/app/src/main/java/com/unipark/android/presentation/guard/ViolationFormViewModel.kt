package com.unipark.android.presentation.guard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.unipark.android.domain.usecases.ReportViolationUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.UUID
import javax.inject.Inject

data class ViolationFormState(
    val plate: String = "",
    val selectedLotName: String = "Lote A",
    val reason: String = "",
    val photoUri: String? = null,
    val saved: Boolean = false,
    val error: String? = null,
)

@HiltViewModel
class ViolationFormViewModel @Inject constructor(
    private val reportViolationUseCase: ReportViolationUseCase,
    private val guardStateStore: GuardStateStore,
) : ViewModel() {
    private val _state = MutableStateFlow(ViolationFormState())
    val state: StateFlow<ViolationFormState> = _state.asStateFlow()
    val infractions = guardStateStore.infractions

    fun setReason(reason: String) {
        _state.value = _state.value.copy(reason = reason)
    }

    fun setPlate(plate: String) {
        _state.value = _state.value.copy(plate = plate.uppercase())
    }

    fun selectLot(lot: String) {
        _state.value = _state.value.copy(selectedLotName = lot)
    }

    fun clearSuccess() {
        _state.value = _state.value.copy(saved = false)
    }

    fun submit(vehicleId: UUID, lotId: UUID) {
        viewModelScope.launch {
            val record = InfractionRecord(
                plate = _state.value.plate,
                lotName = _state.value.selectedLotName,
                reason = _state.value.reason,
                photoUri = _state.value.photoUri,
            )
            guardStateStore.addInfraction(record)
            runCatching {
                reportViolationUseCase.execute(vehicleId, lotId, _state.value.reason, _state.value.photoUri)
            }
                .onSuccess { _state.value = ViolationFormState(saved = true) }
                .onFailure { _state.value = _state.value.copy(error = it.message) }
        }
    }
}
