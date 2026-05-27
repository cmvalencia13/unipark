package com.unipark.backend.controller

import com.unipark.backend.domain.SystemSetting
import com.unipark.backend.domain.SystemSettings
import com.unipark.backend.domain.UpdateSettingsRequest
import com.unipark.backend.repository.SystemSettingRepository
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/v1/admin/settings")
class AdminSettingsController(
    private val systemSettingRepository: SystemSettingRepository
) {

    @GetMapping
    @PreAuthorize("hasRole('SUPERADMIN')")
    fun getSettings(): SystemSettings {
        val map = systemSettingRepository.findAll().associate { it.key to it.value }
        return SystemSettings(
            occupancyWarningPercent = map["occupancy.warning.percent"]?.toIntOrNull() ?: 80,
            occupancyCriticalPercent = map["occupancy.critical.percent"]?.toIntOrNull() ?: 90,
            rateLimitRequests = map["rate.limit.requests"]?.toIntOrNull() ?: 5,
            rateLimitWindowSeconds = map["rate.limit.window.seconds"]?.toIntOrNull() ?: 10,
            qrExpirySeconds = map["qr.expiry.seconds"]?.toIntOrNull() ?: 60,
            maintenanceMode = map["maintenance.mode"]?.toBooleanStrictOrNull() ?: false
        )
    }

    @PatchMapping
    @PreAuthorize("hasRole('SUPERADMIN')")
    fun updateSettings(@RequestBody request: UpdateSettingsRequest): SystemSettings {
        request.occupancyWarningPercent?.let { systemSettingRepository.save(SystemSetting("occupancy.warning.percent", it.toString())) }
        request.occupancyCriticalPercent?.let { systemSettingRepository.save(SystemSetting("occupancy.critical.percent", it.toString())) }
        request.rateLimitRequests?.let { systemSettingRepository.save(SystemSetting("rate.limit.requests", it.toString())) }
        request.rateLimitWindowSeconds?.let { systemSettingRepository.save(SystemSetting("rate.limit.window.seconds", it.toString())) }
        request.qrExpirySeconds?.let { systemSettingRepository.save(SystemSetting("qr.expiry.seconds", it.toString())) }
        request.maintenanceMode?.let { systemSettingRepository.save(SystemSetting("maintenance.mode", it.toString())) }

        return getSettings()
    }
}
