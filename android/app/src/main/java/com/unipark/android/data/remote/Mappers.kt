package com.unipark.android.data.remote

import com.unipark.android.domain.entities.LotOccupancyUpdate
import com.unipark.android.domain.entities.ParkingLot
import com.unipark.android.domain.entities.Pass
import com.unipark.android.domain.entities.Scan
import com.unipark.android.domain.entities.ScanDirection
import com.unipark.android.domain.entities.ScanStatus
import com.unipark.android.domain.entities.User
import com.unipark.android.domain.entities.UserRole
import com.unipark.android.domain.entities.Vehicle
import com.unipark.android.domain.entities.Violation
import com.unipark.android.domain.entities.ViolationStatus
import java.time.Instant
import java.util.UUID

fun UserDto.toDomain() = User(
    id = UUID.fromString(id),
    email = email,
    fullName = fullName,
    role = UserRole.valueOf(role),
    active = active,
)

fun VehicleDto.toDomain() = Vehicle(
    id = UUID.fromString(id),
    ownerId = UUID.fromString(ownerId),
    plate = plate,
    make = make,
    model = model,
    color = color,
    active = active,
)

fun LotDto.toDomain() = ParkingLot(
    id = UUID.fromString(id),
    name = name,
    capacityTotal = capacityTotal,
    capacityUsed = capacityUsed,
    active = active,
)

fun PassDto.toDomain() = Pass(
    id = UUID.fromString(id),
    userId = UUID.fromString(userId),
    vehicleId = UUID.fromString(vehicleId),
    lotId = lotId?.let(UUID::fromString),
    payload = payload,
    signature = signature,
    expiresAt = Instant.parse(expiresAt),
    active = active,
)

fun ScanResponseDto.toDomain() = Scan(
    id = UUID.fromString(id),
    passId = UUID.fromString(passId),
    lotId = UUID.fromString(lotId),
    guardId = UUID.fromString(guardId),
    direction = ScanDirection.valueOf(direction),
    status = ScanStatus.valueOf(status),
    scannedAt = Instant.parse(scannedAt),
)

fun ViolationDto.toDomain() = Violation(
    id = UUID.fromString(id),
    vehicleId = UUID.fromString(vehicleId),
    lotId = UUID.fromString(lotId),
    guardId = UUID.fromString(guardId),
    reason = reason,
    photoUri = photoUri,
    status = ViolationStatus.valueOf(status),
    createdAt = Instant.parse(createdAt),
)

fun LotOccupancyUpdateDto.toDomain() = LotOccupancyUpdate(
    lotId = UUID.fromString(lotId),
    capacityUsed = capacityUsed,
    capacityTotal = capacityTotal,
)
