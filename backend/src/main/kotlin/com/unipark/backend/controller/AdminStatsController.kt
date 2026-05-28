package com.unipark.backend.controller

import com.unipark.backend.domain.AdminStats
import com.unipark.backend.domain.LotOccupancy
import com.unipark.backend.domain.ViolationStatus
import com.unipark.backend.repository.ParkingLotRepository
import com.unipark.backend.repository.ScanRepository
import com.unipark.backend.repository.UserRepository
import com.unipark.backend.repository.ViolationRepository
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.OffsetDateTime
import java.time.ZoneOffset

@RestController
@RequestMapping("/v1/admin")
class AdminStatsController(
    private val parkingLotRepository: ParkingLotRepository,
    private val scanRepository: ScanRepository,
    private val violationRepository: ViolationRepository,
    private val userRepository: UserRepository
) {

    @GetMapping("/stats")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
    fun getStats(): AdminStats {
        val lots = parkingLotRepository.findAll().map { lot ->
            LotOccupancy(lot.name, lot.capacityTotal, lot.capacityUsed)
        }
        val todayStart = OffsetDateTime.now(ZoneOffset.UTC).toLocalDate().atStartOfDay().atOffset(ZoneOffset.UTC)
        val todayScans = scanRepository.countByScannedAtAfter(todayStart)
        val pendingViolations = violationRepository.countByStatus(ViolationStatus.PENDING)
        val totalUsers = userRepository.count()

        return AdminStats(lots, todayScans, pendingViolations, totalUsers)
    }
}
