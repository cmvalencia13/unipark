package com.unipark.backend.controller

import com.unipark.backend.domain.ResolveViolationRequest
import com.unipark.backend.domain.ViolationStatus
import com.unipark.backend.domain.ViolationSummary
import com.unipark.backend.repository.AuditLogRepository
import com.unipark.backend.repository.UserRepository
import com.unipark.backend.repository.ViolationRepository
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.data.repository.findByIdOrNull
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.*
import java.time.OffsetDateTime
import java.util.UUID

@RestController
@RequestMapping("/v1/admin/violations")
class AdminViolationController(
    private val violationRepository: ViolationRepository,
    private val userRepository: UserRepository,
    private val auditLogRepository: AuditLogRepository
) {

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
    fun listViolations(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int,
        @RequestParam(required = false) status: ViolationStatus?,
        @RequestParam(required = false) lotId: UUID?
    ): Page<ViolationSummary> {
        return violationRepository.findFilteredViolations(status, lotId, PageRequest.of(page, size))
            .map { v ->
                ViolationSummary(
                    id = v.id,
                    vehiclePlate = v.vehicle?.plateLast4,
                    guardName = v.guard.fullName,
                    lotName = v.lot?.name,
                    reason = v.reason,
                    status = v.status,
                    evidenceUrl = v.evidenceUrl,
                    createdAt = v.createdAt
                )
            }
    }

    @PatchMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
    fun resolveViolation(
        @PathVariable id: UUID,
        @RequestBody request: ResolveViolationRequest,
        @AuthenticationPrincipal jwt: Jwt
    ): ResponseEntity<ViolationSummary> {
        val existing = violationRepository.findByIdOrNull(id)
            ?: return ResponseEntity.notFound().build()

        if (request.status !in listOf(ViolationStatus.APPROVED, ViolationStatus.DISMISSED)) {
            return ResponseEntity.badRequest().build()
        }

        val resolverId = UUID.fromString(jwt.subject)
        val resolved = existing.copy(
            status = request.status,
            resolvedBy = userRepository.getReferenceById(resolverId),
            resolvedAt = OffsetDateTime.now()
        )
        violationRepository.save(resolved)

        return ResponseEntity.ok(
            ViolationSummary(
                id = resolved.id,
                vehiclePlate = resolved.vehicle?.plateLast4,
                guardName = resolved.guard.fullName,
                lotName = resolved.lot?.name,
                reason = resolved.reason,
                status = resolved.status,
                evidenceUrl = resolved.evidenceUrl,
                createdAt = resolved.createdAt
            )
        )
    }
}
