package com.unipark.backend.controller

import com.unipark.backend.domain.*
import com.unipark.backend.repository.AuditLogRepository
import com.unipark.backend.repository.UserRepository
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.data.repository.findByIdOrNull
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/v1/admin/users")
class AdminUserController(
    private val userRepository: UserRepository,
    private val auditLogRepository: AuditLogRepository
) {

    @GetMapping
    @PreAuthorize("hasRole('SUPERADMIN')")
    fun listUsers(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int,
        @RequestParam(required = false) role: Role?,
        @RequestParam(required = false) search: String?
    ): Page<UserSummary> {
        return userRepository.findFilteredUsers(role, search, PageRequest.of(page, size))
            .map { u -> UserSummary(u.id, u.email, u.fullName, u.role, u.universityId, u.active, u.createdAt) }
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('SUPERADMIN')")
    fun getUser(@PathVariable id: UUID): ResponseEntity<UserSummary> {
        val user = userRepository.findByIdOrNull(id)
            ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(UserSummary(user.id, user.email, user.fullName, user.role, user.universityId, user.active, user.createdAt))
    }

    @PatchMapping("/{id}")
    @PreAuthorize("hasRole('SUPERADMIN')")
    fun updateUser(@PathVariable id: UUID, @RequestBody request: UpdateUserRequest): ResponseEntity<UserSummary> {
        val existing = userRepository.findByIdOrNull(id)
            ?: return ResponseEntity.notFound().build()

        val updated = existing.copy(
            role = request.role ?: existing.role,
            active = request.active ?: existing.active,
            driverCategory = request.driverCategory ?: existing.driverCategory
        )
        userRepository.save(updated)

        return ResponseEntity.ok(
            UserSummary(updated.id, updated.email, updated.fullName, updated.role, updated.universityId, updated.active, updated.createdAt)
        )
    }
}
