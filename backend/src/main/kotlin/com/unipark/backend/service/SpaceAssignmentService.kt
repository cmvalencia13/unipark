package com.unipark.backend.service

import com.unipark.backend.domain.*
import com.unipark.backend.repository.ParkingLotRepository
import com.unipark.backend.repository.ParkingSpaceRepository
import com.unipark.backend.repository.UserRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class SpaceAssignmentService(
    private val userRepository: UserRepository,
    private val parkingLotRepository: ParkingLotRepository,
    private val parkingSpaceRepository: ParkingSpaceRepository
) {

    @Transactional
    fun assignSpace(userId: UUID, lotId: UUID): ParkingSpace {
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("User not found") }

        if (user.role != Role.driver || user.driverCategory == null) {
            throw IllegalArgumentException("User is not a valid driver")
        }

        val lot = parkingLotRepository.findById(lotId)
            .orElseThrow { IllegalArgumentException("Parking lot not found") }

        if (lot.capacityUsed >= lot.capacityTotal) {
            throw IllegalStateException("Parking lot is full")
        }

        val allowedSpaceTypes = when (user.driverCategory) {
            DriverCategory.staff -> listOf(ReservedFor.staff, ReservedFor.general)
            DriverCategory.student -> listOf(ReservedFor.general)
            DriverCategory.visitor -> listOf(ReservedFor.visitor)
            null -> throw IllegalArgumentException("Driver category is missing")
        }

        val availableSpace = parkingSpaceRepository.findFirstByLotIdAndAssignedUserIsNullAndReservedForIn(
            lotId = lot.id,
            reservedFor = allowedSpaceTypes
        ) ?: throw IllegalStateException("No suitable space available in this lot")

        val updatedSpace = parkingSpaceRepository.save(availableSpace.copy(assignedUser = user))
        parkingLotRepository.save(lot.copy(capacityUsed = lot.capacityUsed + 1))

        return updatedSpace
    }
}
