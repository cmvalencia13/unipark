package com.unipark.backend.controller

import com.unipark.backend.domain.AuditEntry
import com.unipark.backend.repository.AuditLogRepository
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import tools.jackson.module.kotlin.jacksonObjectMapper
import java.time.OffsetDateTime
import java.util.UUID

@RestController
@RequestMapping("/v1/admin/audit")
class AdminAuditController(
    private val auditLogRepository: AuditLogRepository
) {

    @GetMapping
    @PreAuthorize("hasRole('SUPERADMIN')")
    fun listAudit(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "50") size: Int,
        @RequestParam(required = false) from: OffsetDateTime?,
        @RequestParam(required = false) to: OffsetDateTime?,
        @RequestParam(required = false) actor: UUID?,
        @RequestParam(required = false) action: String?
    ): Page<AuditEntry> {
        return auditLogRepository.findFilteredAuditLogs(from, to, actor, action, PageRequest.of(page, size))
            .map { a ->
                AuditEntry(
                    id = a.id,
                    actorId = a.actorId,
                    action = a.action,
                    targetId = a.targetId,
                    payload = a.payload?.let { node ->
                        try {
                            jacksonObjectMapper().readValue(node.toString(), Map::class.java) as Map<String, Any?>
                        } catch (e: Exception) {
                            emptyMap()
                        }
                    },
                    ip = a.ip,
                    createdAt = a.createdAt
                )
            }
    }
}
