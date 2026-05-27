package com.unipark.backend.controller

import com.unipark.backend.domain.ParkingSpace
import com.unipark.backend.service.SpaceAssignmentService
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

data class SpaceAssignmentRequest(
    val lotId: UUID
)

@RestController
@RequestMapping("/v1/spaces")
class SpaceAssignmentController(
    private val spaceAssignmentService: SpaceAssignmentService
) {

    @PostMapping("/assign")
    @PreAuthorize("hasAnyRole('DRIVER', 'ADMIN', 'SUPERADMIN')")
    fun assignSpace(
        @RequestBody request: SpaceAssignmentRequest,
        authentication: Authentication
    ): ParkingSpace {
        val userId = UUID.fromString(authentication.name)
        return spaceAssignmentService.assignSpace(userId, request.lotId)
    }
}
