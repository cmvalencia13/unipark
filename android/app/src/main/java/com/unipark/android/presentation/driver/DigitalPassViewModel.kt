package com.unipark.android.presentation.driver

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.unipark.android.domain.entities.Pass
import com.unipark.android.domain.usecases.GeneratePassUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.UUID
import javax.inject.Inject

data class DigitalPassState(
    val pass: Pass? = null,
    val secondsRemaining: Int = 60,
    val loading: Boolean = false,
    val error: String? = null,
    val nonce: String = UUID.randomUUID().toString(),
)

@HiltViewModel
class DigitalPassViewModel @Inject constructor(
    private val generatePassUseCase: GeneratePassUseCase,
) : ViewModel() {
    private val _state = MutableStateFlow(DigitalPassState())
    val state: StateFlow<DigitalPassState> = _state.asStateFlow()
    private var countdownJob: Job? = null

    fun generate(vehicleId: UUID) {
        viewModelScope.launch {
            countdownJob?.cancel()
            _state.value = DigitalPassState(loading = true, nonce = UUID.randomUUID().toString())
            runCatching { generatePassUseCase.execute(vehicleId) }
                .onSuccess {
                    _state.value = DigitalPassState(
                        pass = it,
                        secondsRemaining = 60,
                        nonce = UUID.randomUUID().toString(),
                    )
                    startCountdown(vehicleId)
                }
                .onFailure { _state.value = DigitalPassState(error = it.message) }
        }
    }

    private fun startCountdown(vehicleId: UUID) {
        countdownJob = viewModelScope.launch {
            while (_state.value.secondsRemaining > 0) {
                delay(1_000)
                _state.value = _state.value.copy(secondsRemaining = _state.value.secondsRemaining - 1)
            }
            generate(vehicleId)
        }
    }
}
