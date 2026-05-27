package com.unipark.backend.controller

import com.unipark.backend.domain.Direction
import com.unipark.backend.domain.Scan
import com.unipark.backend.service.ScanValidationService
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

data class ScanRequest(
    val qrPayload: String,
    val lotId: UUID,
    val direction: Direction
)

@RestController
@RequestMapping("/v1/scans")
class ScanController(
    private val scanValidationService: ScanValidationService
) {

    @PostMapping
    @PreAuthorize("hasRole('GUARD')")
    fun recordScan(
        @RequestBody request: ScanRequest,
        @RequestHeader("Idempotency-Key") idempotencyKey: String,
        authentication: Authentication
    ): Scan {
        val guardId = UUID.fromString(authentication.name)
        
        return scanValidationService.validateAndRecordScan(
            qrPayload = request.qrPayload,
            guardId = guardId,
            lotId = request.lotId,
            direction = request.direction,
            idempotencyKey = idempotencyKey
        )
    }
}
