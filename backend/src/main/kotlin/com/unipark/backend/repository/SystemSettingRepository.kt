package com.unipark.backend.repository

import com.unipark.backend.domain.SystemSetting
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface SystemSettingRepository : JpaRepository<SystemSetting, String>
