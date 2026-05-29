package com.unipark.backend.controller

import com.unipark.backend.domain.Pass
import com.unipark.backend.domain.Direction
import com.unipark.backend.repository.PassRepository
import com.unipark.backend.repository.ScanRepository
import com.unipark.backend.repository.UserRepository
import com.unipark.backend.repository.VehicleRepository
import com.unipark.backend.service.QrService
import org.springframework.data.domain.PageRequest
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.time.OffsetDateTime
import java.util.UUID

data class PassRequest(val vehicleId: UUID)

data class ActivePassResponse(
    val passId: UUID,
    val nonce: String,
    val qrPayload: String,    // "nonce:HMAC-signature" — listo para mostrar como QR
    val expiresAt: OffsetDateTime
)

data class DriverStatusResponse(
    val isParked: Boolean,           // true = está dentro del parqueo
    val lotName: String?,            // nombre del lote donde está
    val direction: String?,          // "ENTRY" o "EXIT" del último scan
    val scannedAt: String?           // timestamp del último scan
)

@RestController
@RequestMapping("/v1/passes")
class PassController(
    private val passRepository: PassRepository,
    private val vehicleRepository: VehicleRepository,
    private val userRepository: UserRepository,
    private val scanRepository: ScanRepository,
    private val qrService: QrService
) {

    /**
     * Devuelve el pass activo del conductor con el payload QR firmado por el backend.
     * Si no tiene pass activo, auto-crea uno de 12h usando su primer vehículo.
     * iOS muestra este payload directamente — no genera HMAC en el dispositivo.
     */
    @GetMapping("/active")
    @PreAuthorize("hasRole('DRIVER')")
    fun getActivePass(authentication: Authentication): ActivePassResponse {
        val user = userRepository.findByEmail(authentication.name)
            ?: throw NoSuchElementException("User not found")
        val userId = user.id
        val now = OffsetDateTime.now()

        val pass = passRepository.findTopByUserIdAndExpiresAtAfterOrderByExpiresAtDesc(userId, now)
            ?: run {
                // Auto-crear pass si no existe o expiró
                val vehicle = vehicleRepository.findFirstByOwnerId(userId)
                    ?: throw NoSuchElementException("No vehicle registered — add a vehicle first")
                passRepository.save(
                    Pass(
                        id        = UUID.randomUUID(),
                        user      = user,
                        vehicle   = vehicle,
                        issuedAt  = now,
                        expiresAt = now.plusHours(12),
                        nonce     = UUID.randomUUID().toString()
                    )
                )
            }

        return ActivePassResponse(
            passId    = pass.id,
            nonce     = pass.nonce,
            qrPayload = qrService.buildPayload(pass.nonce),
            expiresAt = pass.expiresAt
        )
    }

    /**
     * Estado de parking del conductor: ¿está dentro o fuera?
     * Mira el último scan de cualquier pass del usuario.
     */
    @GetMapping("/my-status")
    @PreAuthorize("hasRole('DRIVER')")
    fun getMyStatus(authentication: Authentication): DriverStatusResponse {
        val userId = userRepository.findByEmail(authentication.name)
            ?.id ?: throw NoSuchElementException("User not found")
        val lastScan = scanRepository
            .findTopByPassUserIdOrderByScannedAtDesc(userId, PageRequest.of(0, 1))
            .content
            .firstOrNull()

        return if (lastScan == null) {
            DriverStatusResponse(isParked = false, lotName = null, direction = null, scannedAt = null)
        } else {
            DriverStatusResponse(
                isParked  = lastScan.direction == Direction.ENTRY,
                lotName   = lastScan.lot.name,
                direction = lastScan.direction.name,
                scannedAt = lastScan.scannedAt.toString()
            )
        }
    }

    /**
     * Genera un nuevo pass para el conductor (12h de validez).
     */
    @PostMapping
    @PreAuthorize("hasRole('DRIVER')")
    fun generatePass(
        @RequestBody request: PassRequest,
        authentication: Authentication
    ): Pass {
        val user = userRepository.findByEmail(authentication.name)
            ?: throw IllegalArgumentException("User not found")
        val userId = user.id

        val vehicle = vehicleRepository.findById(request.vehicleId)
            .orElseThrow { IllegalArgumentException("Vehicle not found") }

        if (vehicle.owner.id != userId)
            throw IllegalArgumentException("Vehicle does not belong to the user")

        val now = OffsetDateTime.now()
        return passRepository.save(
            Pass(
                id        = UUID.randomUUID(),
                user      = user,
                vehicle   = vehicle,
                issuedAt  = now,
                expiresAt = now.plusHours(12),
                nonce     = UUID.randomUUID().toString()
            )
        )
    }
}
