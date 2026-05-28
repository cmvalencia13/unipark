package com.unipark.backend.service

import com.unipark.backend.domain.*
import com.unipark.backend.repository.ParkingLotRepository
import com.unipark.backend.repository.PassRepository
import com.unipark.backend.repository.ScanRepository
import com.unipark.backend.repository.UserRepository
import org.springframework.beans.factory.annotation.Value
import org.springframework.data.redis.core.StringRedisTemplate
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Duration
import java.time.OffsetDateTime
import java.util.Base64
import java.util.UUID
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

@Service
class ScanValidationService(
    private val passRepository: PassRepository,
    private val scanRepository: ScanRepository,
    private val userRepository: UserRepository,
    private val parkingLotRepository: ParkingLotRepository,
    private val redisTemplate: StringRedisTemplate,
    @Value("\${app.security.qr-secret:default-secret-key-change-me}")
    private val qrSecret: String
) {

    private val MAX_SCANS_PER_MINUTE = 30L

    @Transactional
    fun validateAndRecordScan(
        qrPayload: String, // format: "nonce:signature"
        guardId: UUID,
        lotId: UUID,
        direction: Direction,
        idempotencyKey: String
    ): Scan {
        // 1. Rate Limiting via Redis
        val rateLimitKey = "rate_limit:guard:$guardId"
        val currentRequests = redisTemplate.opsForValue().increment(rateLimitKey) ?: 1L
        if (currentRequests == 1L) {
            redisTemplate.expire(rateLimitKey, Duration.ofMinutes(1))
        }
        if (currentRequests > MAX_SCANS_PER_MINUTE) {
            throw IllegalStateException("Too Many Requests: Rate limit exceeded for guard")
        }

        // 2. Idempotency Check
        if (scanRepository.existsByGuardIdAndIdempotencyKey(guardId, idempotencyKey)) {
            throw IllegalArgumentException("Duplicate scan request")
        }

        // 3. QR Signature Validation
        val parts = qrPayload.split(":")
        if (parts.size != 2) {
            throw IllegalArgumentException("Invalid QR payload format")
        }
        val nonce = parts[0]
        val signature = parts[1]

        if (!verifyHmac(nonce, signature)) {
            throw IllegalArgumentException("Invalid QR signature")
        }

        // 4. Validate Pass
        val pass = passRepository.findByNonce(nonce)
            ?: throw IllegalArgumentException("Pass not found")

        val now = OffsetDateTime.now()
        if (now.isBefore(pass.issuedAt) || now.isAfter(pass.expiresAt)) {
            throw IllegalStateException("Pass is expired or not yet valid")
        }

        // 5. Fetch Guard and Lot
        val guard = userRepository.findById(guardId)
            .orElseThrow { IllegalArgumentException("Guard not found") }
        if (guard.role != Role.guard) {
            throw IllegalArgumentException("User is not a guard")
        }

        val lot = parkingLotRepository.findById(lotId)
            .orElseThrow { IllegalArgumentException("Parking lot not found") }

        // 6. Record Scan
        val scan = Scan(
            pass = pass,
            guard = guard,
            lot = lot,
            direction = direction,
            scannedAt = now,
            idempotencyKey = idempotencyKey
        )

        return scanRepository.save(scan)
    }

    private fun verifyHmac(data: String, expectedSignature: String): Boolean {
        val mac = Mac.getInstance("HmacSHA256")
        val secretKey = SecretKeySpec(qrSecret.toByteArray(), "HmacSHA256")
        mac.init(secretKey)
        val hash = mac.doFinal(data.toByteArray())
        val computedSignature = Base64.getEncoder().encodeToString(hash)
        return computedSignature == expectedSignature
    }
}
