package com.unipark.backend.service

import com.unipark.backend.domain.*
import com.unipark.backend.repository.ParkingLotRepository
import com.unipark.backend.repository.PassRepository
import com.unipark.backend.repository.ScanRepository
import com.unipark.backend.repository.UserRepository
import org.springframework.data.redis.core.StringRedisTemplate
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Duration
import java.time.OffsetDateTime
import java.util.UUID

@Service
class ScanValidationService(
    private val passRepository: PassRepository,
    private val scanRepository: ScanRepository,
    private val userRepository: UserRepository,
    private val parkingLotRepository: ParkingLotRepository,
    private val redisTemplate: StringRedisTemplate,
    private val qrService: QrService
) {

    private val MAX_SCANS_PER_MINUTE = 30L

    @Transactional
    fun validateAndRecordScan(
        qrPayload: String,
        guardId: UUID,
        lotId: UUID,
        direction: Direction,
        idempotencyKey: String
    ): Scan {

        // 1. Rate limiting por guardia (Redis)
        val rateLimitKey = "rate_limit:guard:$guardId"
        val currentRequests = redisTemplate.opsForValue().increment(rateLimitKey) ?: 1L
        if (currentRequests == 1L) redisTemplate.expire(rateLimitKey, Duration.ofMinutes(1))
        if (currentRequests > MAX_SCANS_PER_MINUTE)
            throw IllegalStateException("Too Many Requests: Rate limit exceeded for guard")

        // 2. Idempotencia — evita duplicados exactos
        if (scanRepository.existsByGuardIdAndIdempotencyKey(guardId, idempotencyKey))
            throw IllegalArgumentException("Duplicate scan request")

        // 3. Validar firma HMAC del payload
        val nonce = qrService.extractNonce(qrPayload)
            ?: throw IllegalArgumentException("Invalid QR payload or signature")

        // 4. Buscar y validar el pass
        val pass = passRepository.findByNonce(nonce)
            ?: throw IllegalArgumentException("Pass not found")

        val now = OffsetDateTime.now()
        if (now.isBefore(pass.issuedAt) || now.isAfter(pass.expiresAt))
            throw IllegalStateException("Pass is expired or not yet valid")

        // 5. Validar que el guardia existe y tiene rol correcto
        val guard = userRepository.findById(guardId)
            .orElseThrow { IllegalArgumentException("Guard not found") }
        if (guard.role != Role.guard)
            throw IllegalArgumentException("User is not a guard")

        val lot = parkingLotRepository.findById(lotId)
            .orElseThrow { IllegalArgumentException("Parking lot not found") }

        // 6. Prevenir ENTRY doble — el conductor debe salir antes de volver a entrar
        val lastScan = scanRepository.findTopByPassIdOrderByScannedAtDesc(pass.id)
        if (lastScan != null) {
            if (direction == Direction.ENTRY && lastScan.direction == Direction.ENTRY)
                throw IllegalStateException(
                    "El conductor ya tiene una entrada registrada en ${lastScan.lot.name}. " +
                    "Debe registrar salida antes de una nueva entrada."
                )
            if (direction == Direction.EXIT && lastScan.direction == Direction.EXIT)
                throw IllegalStateException(
                    "No hay entrada activa para registrar salida."
                )
        } else if (direction == Direction.EXIT) {
            throw IllegalStateException("No hay entrada registrada para este pase.")
        }

        // 7. Actualizar ocupación del lote
        val newCapacityUsed = when (direction) {
            Direction.ENTRY -> minOf(lot.capacityUsed + 1, lot.capacityTotal)
            Direction.EXIT  -> maxOf(lot.capacityUsed - 1, 0)
        }
        val updatedLot = parkingLotRepository.save(lot.copy(capacityUsed = newCapacityUsed))

        // 8. Registrar el scan
        return scanRepository.save(
            Scan(
                pass = pass,
                guard = guard,
                lot = updatedLot,
                direction = direction,
                scannedAt = now,
                idempotencyKey = idempotencyKey
            )
        )
    }
}
