package com.unipark.backend.repository

import com.unipark.backend.domain.*
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
interface UserRepository : JpaRepository<User, UUID> {
    fun findByEmail(email: String): User?
    fun findAllByOrderByCreatedAtDesc(pageable: Pageable): Page<User>

    @Query("""
        SELECT u FROM User u
        WHERE (:role IS NULL OR u.role = :role)
          AND (:search IS NULL OR LOWER(u.fullName) LIKE CONCAT('%', LOWER(CAST(:search AS text)), '%')
               OR LOWER(u.email) LIKE CONCAT('%', LOWER(CAST(:search AS text)), '%')
               OR LOWER(u.universityId) LIKE CONCAT('%', LOWER(CAST(:search AS text)), '%'))
        ORDER BY u.createdAt DESC
    """)
    fun findFilteredUsers(role: Role?, search: String?, pageable: Pageable): Page<User>
}

@Repository
interface VehicleRepository : JpaRepository<Vehicle, UUID>

@Repository
interface ParkingLotRepository : JpaRepository<ParkingLot, UUID>

@Repository
interface ParkingSpaceRepository : JpaRepository<ParkingSpace, UUID> {
    fun findFirstByLotIdAndAssignedUserIsNullAndReservedForIn(lotId: UUID, reservedFor: List<ReservedFor>): ParkingSpace?
}

@Repository
interface PassRepository : JpaRepository<Pass, UUID> {
    fun findByNonce(nonce: String): Pass?
}

@Repository
interface ScanRepository : JpaRepository<Scan, UUID> {
    fun existsByGuardIdAndIdempotencyKey(guardId: UUID, idempotencyKey: String): Boolean
}

@Repository
interface ViolationRepository : JpaRepository<Violation, UUID>

@Repository
interface AuditLogRepository : JpaRepository<AuditLog, Long>

@Repository
interface OutboxEventRepository : JpaRepository<OutboxEvent, UUID>
