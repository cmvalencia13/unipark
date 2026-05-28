package com.unipark.android.presentation.guard

import com.unipark.android.domain.entities.ParkingLot
import com.unipark.android.domain.entities.ScanDirection
import com.unipark.android.domain.entities.ScanStatus
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import java.time.Instant
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

data class GuardScanResult(
    val lotName: String,
    val direction: ScanDirection,
    val status: ScanStatus,
    val message: String,
    val scannedAt: Instant,
)

data class InfractionRecord(
    val id: UUID = UUID.randomUUID(),
    val plate: String,
    val lotName: String,
    val reason: String,
    val status: String = "PENDIENTE",
    val photoUri: String? = null,
    val createdAt: Instant = Instant.now(),
)

@Singleton
class GuardStateStore @Inject constructor() {
    private val _lots = MutableStateFlow(
        listOf(
            ParkingLot(UUID(0, 1), "Lote A", capacityTotal = 120, capacityUsed = 62, active = true),
            ParkingLot(UUID(0, 2), "Lote B", capacityTotal = 80, capacityUsed = 66, active = true),
            ParkingLot(UUID(0, 3), "Lote C", capacityTotal = 45, capacityUsed = 45, active = true),
        ),
    )
    val lots: StateFlow<List<ParkingLot>> = _lots.asStateFlow()

    private val _lastScanResult = MutableStateFlow<GuardScanResult?>(null)
    val lastScanResult: StateFlow<GuardScanResult?> = _lastScanResult.asStateFlow()

    private val _infractions = MutableStateFlow(
        listOf(
            InfractionRecord(
                plate = "P123-456",
                lotName = "Lote C",
                reason = "Vehiculo parqueado en lote incorrecto",
                status = "PENDIENTE",
            ),
        ),
    )
    val infractions: StateFlow<List<InfractionRecord>> = _infractions.asStateFlow()

    fun applyScan(lotId: UUID, lotName: String, direction: ScanDirection): GuardScanResult {
        val currentLot = _lots.value.firstOrNull { it.id == lotId }
        val result = when {
            currentLot == null -> GuardScanResult(
                lotName = lotName,
                direction = direction,
                status = ScanStatus.REJECTED,
                message = "Lote no encontrado",
                scannedAt = Instant.now(),
            )
            direction == ScanDirection.ENTRY && currentLot.isFull -> GuardScanResult(
                lotName = currentLot.name,
                direction = direction,
                status = ScanStatus.REJECTED,
                message = "Lote lleno",
                scannedAt = Instant.now(),
            )
            direction == ScanDirection.EXIT && currentLot.capacityUsed <= 0 -> GuardScanResult(
                lotName = currentLot.name,
                direction = direction,
                status = ScanStatus.REJECTED,
                message = "No hay ocupacion para salida",
                scannedAt = Instant.now(),
            )
            else -> {
                val delta = if (direction == ScanDirection.ENTRY) 1 else -1
                _lots.update { lots ->
                    lots.map { lot ->
                        if (lot.id == lotId) {
                            lot.copy(capacityUsed = (lot.capacityUsed + delta).coerceIn(0, lot.capacityTotal))
                        } else {
                            lot
                        }
                    }
                }
                GuardScanResult(
                    lotName = currentLot.name,
                    direction = direction,
                    status = ScanStatus.ACCEPTED,
                    message = if (direction == ScanDirection.ENTRY) "Entrada registrada" else "Salida registrada",
                    scannedAt = Instant.now(),
                )
            }
        }
        _lastScanResult.value = result
        return result
    }

    fun addInfraction(record: InfractionRecord) {
        _infractions.update { current -> listOf(record) + current }
    }
}
