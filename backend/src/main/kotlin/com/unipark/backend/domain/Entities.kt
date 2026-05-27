package com.unipark.backend.domain

import com.fasterxml.jackson.databind.JsonNode
import jakarta.persistence.*
import org.hibernate.annotations.CreationTimestamp
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.time.OffsetDateTime
import java.util.UUID

enum class Role { driver, guard, admin, superadmin }
enum class DriverCategory { staff, student, visitor }
enum class ReservedFor { staff, visitor, general }
enum class Direction { ENTRY, EXIT }
enum class ViolationStatus { PENDING, APPROVED, DISMISSED }

@Entity
@Table(name = "users")
data class User(
    @Id val id: UUID = UUID.randomUUID(),
    @Column(nullable = false, unique = true, columnDefinition = "CITEXT") val email: String,
    @Column(name = "full_name", nullable = false) val fullName: String,
    @Enumerated(EnumType.STRING) @Column(nullable = false) val role: Role,
    @Enumerated(EnumType.STRING) @Column(name = "driver_category") val driverCategory: DriverCategory? = null,
    @Column(name = "university_id", nullable = false) val universityId: String,
    @CreationTimestamp @Column(name = "created_at", updatable = false) val createdAt: OffsetDateTime? = null,
    @Column(nullable = false) val active: Boolean = true
)

@Entity
@Table(name = "vehicles")
data class Vehicle(
    @Id val id: UUID = UUID.randomUUID(),
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "owner_id", nullable = false) val owner: User,
    @Column(name = "plate_hash", nullable = false) val plateHash: ByteArray,
    @Column(name = "plate_last4", nullable = false) val plateLast4: String,
    @Column(name = "make_model") val makeModel: String? = null,
    @Column(nullable = false) val active: Boolean = true
)

@Entity
@Table(name = "parking_lots")
data class ParkingLot(
    @Id val id: UUID = UUID.randomUUID(),
    @Column(nullable = false) val name: String,
    @Column(name = "capacity_total", nullable = false) val capacityTotal: Int,
    @Column(name = "capacity_used", nullable = false) val capacityUsed: Int = 0,
    @Version @Column(nullable = false) val version: Long = 0,
    // @Column(columnDefinition = "geography(POINT, 4326)") val geo: Any? = null, // Requires hibernate-spatial for proper mapping
    @Column(nullable = false) val active: Boolean = true
)

@Entity
@Table(name = "parking_spaces")
data class ParkingSpace(
    @Id val id: UUID = UUID.randomUUID(),
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "lot_id", nullable = false) val lot: ParkingLot,
    @Column(name = "space_identifier", nullable = false) val spaceIdentifier: String,
    @Enumerated(EnumType.STRING) @Column(name = "reserved_for", nullable = false) val reservedFor: ReservedFor,
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "assigned_user_id") val assignedUser: User? = null
)

@Entity
@Table(name = "passes")
data class Pass(
    @Id val id: UUID = UUID.randomUUID(),
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "user_id", nullable = false) val user: User,
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "vehicle_id", nullable = false) val vehicle: Vehicle,
    @Column(name = "issued_at", nullable = false) val issuedAt: OffsetDateTime,
    @Column(name = "expires_at", nullable = false) val expiresAt: OffsetDateTime,
    @Column(nullable = false, unique = true) val nonce: String
)

@Entity
@Table(name = "scans")
data class Scan(
    @Id val id: UUID = UUID.randomUUID(),
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "pass_id", nullable = false) val pass: Pass,
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "guard_id", nullable = false) val guard: User,
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "lot_id", nullable = false) val lot: ParkingLot,
    @Enumerated(EnumType.STRING) @Column(nullable = false) val direction: Direction,
    @Column(name = "scanned_at", nullable = false) val scannedAt: OffsetDateTime,
    @Column(name = "idempotency_key", nullable = false) val idempotencyKey: String
)

@Entity
@Table(name = "violations")
data class Violation(
    @Id val id: UUID = UUID.randomUUID(),
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "vehicle_id") val vehicle: Vehicle? = null,
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "guard_id", nullable = false) val guard: User,
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "lot_id") val lot: ParkingLot? = null,
    @Column(nullable = false) val reason: String,
    @Column(name = "evidence_url") val evidenceUrl: String? = null,
    @Enumerated(EnumType.STRING) @Column(nullable = false) val status: ViolationStatus = ViolationStatus.PENDING,
    @CreationTimestamp @Column(name = "created_at", updatable = false) val createdAt: OffsetDateTime? = null,
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "resolved_by") val resolvedBy: User? = null,
    @Column(name = "resolved_at") val resolvedAt: OffsetDateTime? = null
)

@Entity
@Table(name = "audit_log")
data class AuditLog(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) val id: Long = 0,
    @Column(name = "actor_id") val actorId: UUID? = null,
    @Column(nullable = false) val action: String,
    @Column(name = "target_id") val targetId: UUID? = null,
    @JdbcTypeCode(SqlTypes.JSON) @Column(columnDefinition = "jsonb") val payload: JsonNode? = null,
    @Column(columnDefinition = "inet") val ip: String? = null,
    @Column(name = "user_agent") val userAgent: String? = null,
    @CreationTimestamp @Column(name = "created_at", nullable = false, updatable = false) val createdAt: OffsetDateTime? = null
)

@Entity
@Table(name = "outbox_events")
data class OutboxEvent(
    @Id val id: UUID = UUID.randomUUID(),
    @Column(nullable = false) val aggregate: String,
    @Column(name = "event_type", nullable = false) val eventType: String,
    @JdbcTypeCode(SqlTypes.JSON) @Column(nullable = false, columnDefinition = "jsonb") val payload: JsonNode,
    @CreationTimestamp @Column(name = "created_at", updatable = false) val createdAt: OffsetDateTime? = null,
    @Column(name = "published_at") val publishedAt: OffsetDateTime? = null
)
