package com.unipark.android.ui.driver

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.unipark.android.data.local.StickerPermitDao
import com.unipark.android.data.local.toEntity
import com.unipark.android.domain.entities.ParkingLot
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.LocalDateTime
import java.util.UUID
import javax.inject.Inject

data class ScanResult(
    val lotName: String,
    val level: String,
    val direction: String,
    val scannedAt: LocalDateTime,
)

data class StickerPermit(
    val userId: UUID,
    val qrContent: String,
    val savedAt: Instant,
)

data class PassPayload(
    val payload: String,
    val expiresAt: Instant,
    val nonce: String,
)

@HiltViewModel
class DriverViewModel @Inject constructor(
    private val stickerPermitDao: StickerPermitDao,
) : ViewModel() {
    private val _lots = MutableStateFlow(stubLots)
    val lots: StateFlow<List<ParkingLot>> = _lots.asStateFlow()

    private val _lastEntryScan = MutableStateFlow<ScanResult?>(demoLastEntry)
    val lastEntryScan: StateFlow<ScanResult?> = _lastEntryScan.asStateFlow()

    private val _stickerPermit = MutableStateFlow<StickerPermit?>(null)
    val stickerPermit: StateFlow<StickerPermit?> = _stickerPermit.asStateFlow()

    private val _passPayload = MutableStateFlow<PassPayload?>(null)
    val passPayload: StateFlow<PassPayload?> = _passPayload.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private var passJob: Job? = null

    init {
        loadData()
        startPassRefresh()
    }

    fun saveStickerPermit(qrContent: String) {
        val stickerPermit = StickerPermit(
            userId = UUID(0, 10),
            qrContent = qrContent,
            savedAt = Instant.now(),
        )
        _stickerPermit.value = stickerPermit
        viewModelScope.launch {
            stickerPermitDao.upsertStickerPermit(stickerPermit.toEntity())
        }
    }

    fun refreshPass() {
        _passPayload.value = PassPayload(
            payload = "unipark-pass:${UUID.randomUUID()}",
            expiresAt = Instant.now().plusSeconds(60),
            nonce = UUID.randomUUID().toString(),
        )
    }

    fun loadData() {
        viewModelScope.launch {
            _isLoading.value = true
            delay(250)
            _lots.value = stubLots
            _stickerPermit.value = stickerPermitDao
                .getStickerPermit(UUID(0, 10).toString())
                ?.toUiModel()
            _isLoading.value = false
        }
    }

    fun simulateScanResult() {
        _lastEntryScan.value = ScanResult(
            lotName = "Lote B",
            level = "Nivel 2",
            direction = "Entrada registrada",
            scannedAt = LocalDateTime.now(),
        )
    }

    private fun startPassRefresh() {
        passJob?.cancel()
        passJob = viewModelScope.launch {
            while (true) {
                refreshPass()
                delay(60_000)
            }
        }
    }

    private companion object {
        val stubLots = listOf(
            ParkingLot(UUID(0, 1), "Lote A", 120, 62, true),
            ParkingLot(UUID(0, 2), "Lote B", 80, 66, true),
            ParkingLot(UUID(0, 3), "Lote C", 45, 45, true),
        )

        val demoLastEntry = ScanResult(
            lotName = "Lote B",
            level = "Nivel 2",
            direction = "Entrada registrada",
            scannedAt = LocalDateTime.now().withHour(8).withMinute(45),
        )
    }
}
