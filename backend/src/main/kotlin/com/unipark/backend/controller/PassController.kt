package com.unipark.backend.controller

import com.unipark.backend.domain.Pass
import com.unipark.backend.repository.PassRepository
import com.unipark.backend.repository.UserRepository
import com.unipark.backend.repository.VehicleRepository
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.time.OffsetDateTime
import java.util.UUID

data class PassRequest(
    val vehicleId: UUID
)

@RestController
@RequestMapping("/v1/passes")
class PassController(
    private val passRepository: PassRepository,
    private val vehicleRepository: VehicleRepository,
    private val userRepository: UserRepository
) {

    @PostMapping
    @PreAuthorize("hasRole('DRIVER')")
    fun generatePass(
        @RequestBody request: PassRequest,
        authentication: Authentication
    ): Pass {
        val userId = UUID.fromString(authentication.name)
        
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("User not found") }
            
        val vehicle = vehicleRepository.findById(request.vehicleId)
            .orElseThrow { IllegalArgumentException("Vehicle not found") }
            
        if (vehicle.owner.id != userId) {
            throw IllegalArgumentException("Vehicle does not belong to the user")
        }
        
        val now = OffsetDateTime.now()
        val pass = Pass(
            id = UUID.randomUUID(),
            user = user,
            vehicle = vehicle,
            issuedAt = now,
            expiresAt = now.plusHours(12),
            nonce = UUID.randomUUID().toString()
        )
        
        return passRepository.save(pass)
    }
}
