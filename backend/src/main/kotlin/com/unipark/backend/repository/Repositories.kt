package com.unipark.backend.repository

import com.unipark.backend.domain.*
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
interface UserRepository : JpaRepository<User, UUID>

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
