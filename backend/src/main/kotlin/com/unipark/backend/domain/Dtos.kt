package com.unipark.backend.domain

import java.time.OffsetDateTime
import java.util.UUID

// --- User Management ---
data class UserSummary(
    val id: UUID,
    val email: String,
    val fullName: String,
    val role: Role,
    val universityId: String,
    val active: Boolean,
    val createdAt: OffsetDateTime?
)

data class UpdateUserRequest(
    val role: Role? = null,
    val active: Boolean? = null,
    val driverCategory: DriverCategory? = null
)

// --- Dashboard Stats ---
data class LotOccupancy(
    val name: String,
    val capacityTotal: Int,
    val capacityUsed: Int
)

data class AdminStats(
    val lots: List<LotOccupancy>,
    val todayScans: Long,
    val pendingViolations: Long,
    val totalUsers: Long
)

// --- Violations ---
data class ViolationSummary(
    val id: UUID,
    val vehiclePlate: String?,
    val guardName: String,
    val lotName: String?,
    val reason: String,
    val status: ViolationStatus,
    val evidenceUrl: String?,
    val createdAt: OffsetDateTime?
)

data class ResolveViolationRequest(
    val status: ViolationStatus,
    val resolutionNote: String
)

// --- Audit ---
data class AuditEntry(
    val id: Long,
    val actorId: UUID?,
    val action: String,
    val targetId: UUID?,
    val payload: Map<String, Any?>?,
    val ip: String?,
    val createdAt: OffsetDateTime?
)

// --- Settings ---
data class SystemSettings(
    val occupancyWarningPercent: Int,
    val occupancyCriticalPercent: Int,
    val rateLimitRequests: Int,
    val rateLimitWindowSeconds: Int,
    val qrExpirySeconds: Int,
    val maintenanceMode: Boolean
)

data class UpdateSettingsRequest(
    val occupancyWarningPercent: Int? = null,
    val occupancyCriticalPercent: Int? = null,
    val rateLimitRequests: Int? = null,
    val rateLimitWindowSeconds: Int? = null,
    val qrExpirySeconds: Int? = null,
    val maintenanceMode: Boolean? = null
)
