# Admin Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a web admin dashboard (Next.js 14) for admin/superadmin roles with role management, backed by new Spring Boot admin API endpoints.

**Architecture:** Next.js App Router talks to Spring Boot REST API under `/v1/admin/`. NextAuth.js v5 handles Keycloak OIDC. Role gating in both Next.js middleware (UI) and Spring Boot `@PreAuthorize` (API). Dark "cyber-academic" theme matching the Android app.

**Tech Stack:** Next.js 14 (App Router), TypeScript 5, Tailwind CSS 3.4, NextAuth.js v5, SWR, Recharts, Spring Boot 4.0, Kotlin 2.2, JPA/Hibernate, PostgreSQL 16

---

## File Structure

```
backend/src/main/kotlin/com/unipark/backend/
├── config/SecurityConfig.kt          (modify)
├── controller/
│   ├── AdminUserController.kt        (create)
│   ├── AdminStatsController.kt       (create)
│   ├── AdminViolationController.kt   (create)
│   ├── AdminAuditController.kt       (create)
│   └── AdminSettingsController.kt    (create)
├── domain/
│   ├── Entities.kt                   (modify: add SystemSetting)
│   └── Dtos.kt                       (create: admin request/response types)
└── repository/
    ├── Repositories.kt               (modify: add SystemSettingRepository)

web/                                   (create entire directory)
├── package.json
├── tsconfig.json
├── next.config.ts
├── tailwind.config.ts
├── postcss.config.js
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── globals.css
│   │   ├── providers.tsx
│   │   ├── (auth)/login/page.tsx
│   │   ├── (admin)/
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx              (redirect to dashboard)
│   │   │   ├── dashboard/page.tsx
│   │   │   ├── lots/page.tsx
│   │   │   ├── violations/page.tsx
│   │   │   └── (superadmin)/
│   │   │       ├── users/page.tsx
│   │   │       ├── audit/page.tsx
│   │   │       └── settings/page.tsx
│   ├── components/
│   │   ├── ui/
│   │   │   ├── GlassPanel.tsx
│   │   │   ├── OccupancyBar.tsx
│   │   │   ├── StatusPill.tsx
│   │   │   ├── StatusDot.tsx
│   │   │   └── Skeleton.tsx
│   │   ├── layout/
│   │   │   ├── Sidebar.tsx
│   │   │   └── Header.tsx
│   │   └── shared/
│   │       ├── DataTable.tsx
│   │       ├── SearchInput.tsx
│   │       ├── FilterDropdown.tsx
│   │       ├── ConfirmDialog.tsx
│   │       └── Toast.tsx
│   ├── lib/
│   │   ├── auth.ts
│   │   ├── auth.config.ts
│   │   └── api.ts
│   └── middleware.ts
```

---

### Task 1: Admin DTOs

**Files:**
- Create: `backend/src/main/kotlin/com/unipark/backend/domain/Dtos.kt`

- [ ] **Step 1: Write Dtos.kt**

```kotlin
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
```

- [ ] **Step 2: Commit**

```bash
git add backend/src/main/kotlin/com/unipark/backend/domain/Dtos.kt
git commit -m "feat: add admin DTOs for user management, stats, violations, audit, and settings"
```

---

### Task 2: SystemSetting Entity + Repository

**Files:**
- Modify: `backend/src/main/kotlin/com/unipark/backend/domain/Entities.kt`
- Create: `backend/src/main/kotlin/com/unipark/backend/repository/SystemSettingRepository.kt`

- [ ] **Step 1: Add SystemSetting entity to Entities.kt**

Append this class after the `OutboxEvent` entity:

```kotlin
@Entity
@Table(name = "system_settings")
data class SystemSetting(
    @Id @Column(name = "setting_key", length = 100) val key: String,
    @Column(name = "setting_value", nullable = false) val value: String
)
```

- [ ] **Step 2: Create SystemSettingRepository**

```kotlin
package com.unipark.backend.repository

import com.unipark.backend.domain.SystemSetting
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface SystemSettingRepository : JpaRepository<SystemSetting, String>
```

- [ ] **Step 3: Commit**

```bash
git add backend/src/main/kotlin/com/unipark/backend/domain/Entities.kt backend/src/main/kotlin/com/unipark/backend/repository/SystemSettingRepository.kt
git commit -m "feat: add SystemSetting entity and repository"
```

---

### Task 3: Admin User Controller

**Files:**
- Create: `backend/src/main/kotlin/com/unipark/backend/controller/AdminUserController.kt`
- Modify: `backend/src/main/kotlin/com/unipark/backend/repository/Repositories.kt`

- [ ] **Step 1: Add query method to UserRepository**

Replace the existing `UserRepository` interface in `Repositories.kt`:

```kotlin
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
```

Add the missing imports at the top of Repositories.kt:
```kotlin
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.Query
```

- [ ] **Step 2: Create AdminUserController**

```kotlin
package com.unipark.backend.controller

import com.unipark.backend.domain.*
import com.unipark.backend.repository.AuditLogRepository
import com.unipark.backend.repository.UserRepository
import com.unipark.backend.repository.ViolationRepository
import org.springframework.data.domain.PageRequest
import org.springframework.data.repository.findByIdOrNull
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/v1/admin/users")
class AdminUserController(
    private val userRepository: UserRepository,
    private val auditLogRepository: AuditLogRepository
) {

    @GetMapping
    @PreAuthorize("hasRole('SUPERADMIN')")
    fun listUsers(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int,
        @RequestParam(required = false) role: Role?,
        @RequestParam(required = false) search: String?
    ): Page<UserSummary> {
        return userRepository.findFilteredUsers(role, search, PageRequest.of(page, size))
            .map { u -> UserSummary(u.id, u.email, u.fullName, u.role, u.universityId, u.active, u.createdAt) }
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('SUPERADMIN')")
    fun getUser(@PathVariable id: UUID): ResponseEntity<UserSummary> {
        val user = userRepository.findByIdOrNull(id)
            ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(UserSummary(user.id, user.email, user.fullName, user.role, user.universityId, user.active, user.createdAt))
    }

    @PatchMapping("/{id}")
    @PreAuthorize("hasRole('SUPERADMIN')")
    fun updateUser(@PathVariable id: UUID, @RequestBody request: UpdateUserRequest): ResponseEntity<UserSummary> {
        val existing = userRepository.findByIdOrNull(id)
            ?: return ResponseEntity.notFound().build()

        // Use data class copy() since entity properties are val
        val updated = existing.copy(
            role = request.role ?: existing.role,
            active = request.active ?: existing.active,
            driverCategory = request.driverCategory ?: existing.driverCategory
        )
        userRepository.save(updated)

        return ResponseEntity.ok(
            UserSummary(updated.id, updated.email, updated.fullName, updated.role, updated.universityId, updated.active, updated.createdAt)
        )
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add backend/src/main/kotlin/com/unipark/backend/controller/AdminUserController.kt backend/src/main/kotlin/com/unipark/backend/repository/Repositories.kt
git commit -m "feat: add admin user controller with list, get, and update endpoints"
```

---

### Task 4: Admin Stats Controller

**Files:**
- Create: `backend/src/main/kotlin/com/unipark/backend/controller/AdminStatsController.kt`
- Modify: `backend/src/main/kotlin/com/unipark/backend/repository/Repositories.kt`

- [ ] **Step 1: Add query methods to repositories**

Add these query methods to the existing repository interfaces (keep existing methods):

In `ScanRepository`:
```kotlin
fun countByScannedAtAfter(after: OffsetDateTime): Long
```

In `ViolationRepository`:
```kotlin
fun countByStatus(status: ViolationStatus): Long
```

In `UserRepository`:
```kotlin
fun count(): Long
```

Add import for `OffsetDateTime` in Repositories.kt:
```kotlin
import java.time.OffsetDateTime
```

- [ ] **Step 2: Create AdminStatsController**

```kotlin
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
```

- [ ] **Step 3: Commit**

```bash
git add backend/src/main/kotlin/com/unipark/backend/controller/AdminStatsController.kt backend/src/main/kotlin/com/unipark/backend/repository/Repositories.kt
git commit -m "feat: add admin stats controller with occupancy, scans, and violation counts"
```

---

### Task 5: Admin Violation Controller

**Files:**
- Create: `backend/src/main/kotlin/com/unipark/backend/controller/AdminViolationController.kt`

- [ ] **Step 1: Add query methods to ViolationRepository**

Add to `ViolationRepository` in `Repositories.kt`:
```kotlin
@Query("""
    SELECT v FROM Violation v
    WHERE (:status IS NULL OR v.status = :status)
      AND (:lotId IS NULL OR v.lot.id = :lotId)
    ORDER BY v.createdAt DESC
""")
fun findFilteredViolations(status: ViolationStatus?, lotId: UUID?, pageable: Pageable): Page<Violation>
```

Add import for `Page` and `Pageable` if not already present.

- [ ] **Step 2: Create AdminViolationController**

```kotlin
package com.unipark.backend.controller

import com.unipark.backend.domain.ResolveViolationRequest
import com.unipark.backend.domain.ViolationStatus
import com.unipark.backend.domain.ViolationSummary
import com.unipark.backend.repository.AuditLogRepository
import com.unipark.backend.repository.UserRepository
import com.unipark.backend.repository.ViolationRepository
import org.springframework.data.domain.PageRequest
import org.springframework.data.repository.findByIdOrNull
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.*
import java.time.OffsetDateTime
import java.util.UUID

@RestController
@RequestMapping("/v1/admin/violations")
class AdminViolationController(
    private val violationRepository: ViolationRepository,
    private val userRepository: UserRepository,
    private val auditLogRepository: AuditLogRepository
) {

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
    fun listViolations(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int,
        @RequestParam(required = false) status: ViolationStatus?,
        @RequestParam(required = false) lotId: UUID?
    ): Page<ViolationSummary> {
        return violationRepository.findFilteredViolations(status, lotId, PageRequest.of(page, size))
            .map { v ->
                ViolationSummary(
                    id = v.id,
                    vehiclePlate = v.vehicle?.plateLast4,
                    guardName = v.guard.fullName,
                    lotName = v.lot?.name,
                    reason = v.reason,
                    status = v.status,
                    evidenceUrl = v.evidenceUrl,
                    createdAt = v.createdAt
                )
            }
    }

    @PatchMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
    fun resolveViolation(
        @PathVariable id: UUID,
        @RequestBody request: ResolveViolationRequest,
        @AuthenticationPrincipal jwt: Jwt
    ): ResponseEntity<ViolationSummary> {
        val existing = violationRepository.findByIdOrNull(id)
            ?: return ResponseEntity.notFound().build()

        if (request.status !in listOf(ViolationStatus.APPROVED, ViolationStatus.DISMISSED)) {
            return ResponseEntity.badRequest().build()
        }

        val resolverId = UUID.fromString(jwt.subject)
        val resolved = existing.copy(
            status = request.status,
            resolvedBy = userRepository.getReferenceById(resolverId),
            resolvedAt = OffsetDateTime.now()
        )
        violationRepository.save(resolved)

        return ResponseEntity.ok(
            ViolationSummary(
                id = resolved.id,
                vehiclePlate = resolved.vehicle?.plateLast4,
                guardName = resolved.guard.fullName,
                lotName = resolved.lot?.name,
                reason = resolved.reason,
                status = resolved.status,
                evidenceUrl = resolved.evidenceUrl,
                createdAt = resolved.createdAt
            )
        )
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add backend/src/main/kotlin/com/unipark/backend/controller/AdminViolationController.kt backend/src/main/kotlin/com/unipark/backend/repository/Repositories.kt
git commit -m "feat: add admin violation controller with list and resolve endpoints"
```

---

### Task 6: Admin Audit Controller

**Files:**
- Create: `backend/src/main/kotlin/com/unipark/backend/controller/AdminAuditController.kt`

- [ ] **Step 1: Add query method to AuditLogRepository**

Add to `AuditLogRepository` in `Repositories.kt`:
```kotlin
@Query("""
    SELECT a FROM AuditLog a
    WHERE (:from IS NULL OR a.createdAt >= :from)
      AND (:to IS NULL OR a.createdAt <= :to)
      AND (:actor IS NULL OR a.actorId = :actor)
      AND (:action IS NULL OR a.action = :action)
    ORDER BY a.createdAt DESC
""")
fun findFilteredAuditLogs(from: OffsetDateTime?, to: OffsetDateTime?, actor: UUID?, action: String?, pageable: Pageable): Page<AuditLog>
```

Ensure `Page` and `Pageable` imports exist, and add `OffsetDateTime` and `UUID` imports.

- [ ] **Step 2: Create AdminAuditController**

```kotlin
package com.unipark.backend.controller

import com.unipark.backend.domain.AuditEntry
import com.unipark.backend.repository.AuditLogRepository
import org.springframework.data.domain.PageRequest
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
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
                        try { com.fasterxml.jackson.module.kotlin.jacksonObjectMapper().readValue(node.toString(), Map::class.java) as Map<String, Any?> }
                        catch (e: Exception) { emptyMap() }
                    },
                    ip = a.ip,
                    createdAt = a.createdAt
                )
            }
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add backend/src/main/kotlin/com/unipark/backend/controller/AdminAuditController.kt backend/src/main/kotlin/com/unipark/backend/repository/Repositories.kt
git commit -m "feat: add admin audit log controller with filtering and pagination"
```

---

### Task 7: Admin Settings Controller

**Files:**
- Create: `backend/src/main/kotlin/com/unipark/backend/controller/AdminSettingsController.kt`

- [ ] **Step 1: Create AdminSettingsController**

```kotlin
package com.unipark.backend.controller

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
```

- [ ] **Step 2: Commit**

```bash
git add backend/src/main/kotlin/com/unipark/backend/controller/AdminSettingsController.kt
git commit -m "feat: add admin settings controller with get and update endpoints"
```

---

### Task 8: Update Security Config for Admin Routes

**Files:**
- Modify: `backend/src/main/kotlin/com/unipark/backend/config/SecurityConfig.kt`

- [ ] **Step 1: Update SecurityConfig to restrict /v1/admin/ endpoints**

Replace the `authorizeHttpRequests` block inside `securityFilterChain`:

```kotlin
@Bean
fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
    http
        .csrf { it.disable() }
        .authorizeHttpRequests { auth ->
            auth.requestMatchers("/v1/admin/**").hasAnyRole("ADMIN", "SUPERADMIN")
            auth.requestMatchers("/v1/**").authenticated()
            auth.anyRequest().permitAll()
        }
        .oauth2ResourceServer { oauth2 ->
            oauth2.jwt { jwt ->
                jwt.jwtAuthenticationConverter(jwtAuthenticationConverter())
            }
        }

    return http.build()
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/src/main/kotlin/com/unipark/backend/config/SecurityConfig.kt
git commit -m "feat: restrict /v1/admin/ endpoints to ADMIN and SUPERADMIN roles"
```

---

### Task 9: Scaffold Next.js Project

**Files:**
- Create: `web/package.json`, `web/tsconfig.json`, `web/next.config.ts`, `web/postcss.config.js`, `web/src/app/layout.tsx`, `web/src/app/globals.css`

- [ ] **Step 1: Create web/package.json**

```json
{
  "name": "unipark-web",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "^14.2.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "next-auth": "5.0.0-beta.25",
    "swr": "^2.2.0",
    "recharts": "^2.12.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "typescript": "^5.4.0",
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0"
  }
}
```

- [ ] **Step 2: Create web/tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{"name": "next"}],
    "paths": {"@/*": ["./src/*"]}
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

- [ ] **Step 3: Create web/next.config.ts**

```typescript
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  serverExternalPackages: [],
};

export default nextConfig;
```

- [ ] **Step 4: Create web/postcss.config.js**

```javascript
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
```

- [ ] **Step 5: Create web/src/app/globals.css**

```css
@import url('https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap');

@tailwind base;
@tailwind components;
@tailwind utilities;

.material-symbols-outlined {
  font-family: 'Material Symbols Outlined';
  font-weight: normal;
  font-style: normal;
  font-size: 24px;
  line-height: 1;
  letter-spacing: normal;
  text-transform: none;
  display: inline-block;
  white-space: nowrap;
  word-wrap: normal;
  direction: ltr;
  -webkit-font-feature-settings: 'liga';
  -webkit-font-smoothing: antialiased;
  font-variation-settings: 'FILL' 0;
}

.material-symbols-outlined.filled {
  font-variation-settings: 'FILL' 1;
}
```

- [ ] **Step 6: Create web/src/app/layout.tsx**

```tsx
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "UniPark Admin",
  description: "University Parking Management — Admin Dashboard",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <body className="bg-[#111317] text-[#e2e2e8] font-sans antialiased min-h-screen">
        {children}
      </body>
    </html>
  );
}
```

- [ ] **Step 7: Install dependencies and verify build**

```bash
cd web && npm install && npm run build
```

Expected: successful build with empty pages.

- [ ] **Step 8: Commit**

```bash
git add web/
git commit -m "feat: scaffold Next.js 14 project with TypeScript and Tailwind CSS"
```

---

### Task 10: Tailwind Config with Unipark Design Tokens

**Files:**
- Create: `web/tailwind.config.ts`

- [ ] **Step 1: Create tailwind.config.ts**

```typescript
import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        background: "#111317",
        surface: "#111317",
        "surface-container": "#1e2024",
        "surface-container-low": "#1a1c20",
        "surface-container-lowest": "#0c0e12",
        "surface-container-high": "#282a2e",
        "surface-container-highest": "#333539",
        "surface-variant": "#333539",
        "surface-bright": "#37393e",
        "surface-dim": "#111317",
        "on-background": "#e2e2e8",
        "on-surface": "#e2e2e8",
        "on-surface-variant": "#b9cacb",
        "primary-fixed": "#7df4ff",
        "primary-fixed-dim": "#00dbe9",
        "primary": "#dbfcff",
        "on-primary": "#00363a",
        "on-primary-container": "#006970",
        "primary-container": "#00f0ff",
        "inverse-primary": "#006970",
        "on-primary-fixed": "#002022",
        "on-primary-fixed-variant": "#004f54",
        "surface-tint": "#00dbe9",
        "secondary-fixed": "#36ffc4",
        "secondary-fixed-dim": "#00e1ab",
        "secondary-container": "#36ffc4",
        "secondary": "#ffffff",
        "on-secondary": "#003828",
        "on-secondary-container": "#007255",
        "on-secondary-fixed": "#002116",
        "on-secondary-fixed-variant": "#00513c",
        error: "#ffb4ab",
        "error-container": "#93000a",
        "on-error": "#690005",
        "on-error-container": "#ffdad6",
        tertiary: "#faf3ff",
        "tertiary-container": "#e1d2ff",
        "tertiary-fixed": "#e9ddff",
        "tertiary-fixed-dim": "#d1bcff",
        "on-tertiary": "#3c0090",
        "on-tertiary-container": "#7213ff",
        "on-tertiary-fixed": "#23005b",
        "on-tertiary-fixed-variant": "#5700c9",
        outline: "#849495",
        "outline-variant": "#3b494b",
        "inverse-surface": "#e2e2e8",
        "inverse-on-surface": "#2f3035",
      },
      borderRadius: {
        DEFAULT: "0.25rem",
        lg: "0.5rem",
        xl: "0.75rem",
        full: "9999px",
      },
      fontFamily: {
        sans: ["Sora", "sans-serif"],
        sora: ["Sora", "sans-serif"],
      },
      fontSize: {
        "display-lg": ["48px", { lineHeight: "56px", letterSpacing: "-0.02em", fontWeight: "700" }],
        "headline-lg": ["32px", { lineHeight: "40px", letterSpacing: "-0.01em", fontWeight: "600" }],
        "headline-md": ["24px", { lineHeight: "32px", fontWeight: "600" }],
        "body-lg": ["18px", { lineHeight: "28px", fontWeight: "400" }],
        "body-md": ["16px", { lineHeight: "24px", fontWeight: "400" }],
        "label-md": ["14px", { lineHeight: "20px", letterSpacing: "0.05em", fontWeight: "500" }],
        "label-sm": ["12px", { lineHeight: "16px", letterSpacing: "0.1em", fontWeight: "600" }],
        "mono-data": ["14px", { lineHeight: "20px", letterSpacing: "0.02em", fontWeight: "700" }],
      },
      spacing: {
        xs: "4px",
        sm: "12px",
        md: "24px",
        lg: "40px",
        xl: "64px",
        gutter: "16px",
      },
      animation: {
        "slide-up-fade": "slideUpFade 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards",
        shimmer: "shimmerLine 2s infinite",
      },
      keyframes: {
        slideUpFade: {
          "0%": { opacity: "0", transform: "translateY(20px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        shimmerLine: {
          "0%": { transform: "translateX(-150%)" },
          "100%": { transform: "translateX(150%)" },
        },
      },
    },
  },
  plugins: [],
};

export default config;
```

- [ ] **Step 2: Commit**

```bash
git add web/tailwind.config.ts
git commit -m "feat: add Unipark design tokens as Tailwind config"
```

---

### Task 11: NextAuth.js Auth Setup

**Files:**
- Create: `web/src/lib/auth.config.ts`, `web/src/lib/auth.ts`, `web/src/app/providers.tsx`
- Modify: `web/src/app/layout.tsx`

- [ ] **Step 1: Create auth.config.ts**

```typescript
import type { NextAuthConfig } from "next-auth";

export const authConfig: NextAuthConfig = {
  pages: {
    signIn: "/login",
  },
  callbacks: {
    authorized({ auth, request: { nextUrl } }) {
      const isLoggedIn = !!auth?.user;
      const isAdminRoute = nextUrl.pathname.startsWith("/admin");

      if (isAdminRoute) {
        if (!isLoggedIn) return false;
        const role = auth?.user?.role as string;
        if (nextUrl.pathname.startsWith("/admin/users") ||
            nextUrl.pathname.startsWith("/admin/audit") ||
            nextUrl.pathname.startsWith("/admin/settings")) {
          return role === "superadmin";
        }
        return role === "admin" || role === "superadmin";
      }

      if (isLoggedIn) {
        return Response.redirect(new URL("/admin/dashboard", nextUrl));
      }
      return true;
    },
    jwt({ token, user }) {
      if (user) {
        token.role = (user as any).role;
        token.sub = user.id;
      }
      return token;
    },
    session({ session, token }) {
      if (session.user) {
        (session.user as any).role = token.role as string;
        session.user.id = token.sub!;
      }
      return session;
    },
  },
  providers: [],
};
```

- [ ] **Step 2: Create auth.ts**

```typescript
import NextAuth from "next-auth";
import Keycloak from "next-auth/providers/keycloak";
import { authConfig } from "./auth.config";

export const { handlers, signIn, signOut, auth } = NextAuth({
  ...authConfig,
  providers: [
    Keycloak({
      clientId: process.env.AUTH_KEYCLOAK_ID!,
      clientSecret: process.env.AUTH_KEYCLOAK_SECRET!,
      issuer: process.env.AUTH_KEYCLOAK_ISSUER!,
    }),
  ],
});
```

- [ ] **Step 3: Create providers.tsx**

```tsx
"use client";

import { SessionProvider } from "next-auth/react";

export function Providers({ children }: { children: React.ReactNode }) {
  return <SessionProvider>{children}</SessionProvider>;
}
```

- [ ] **Step 4: Update layout.tsx to wrap with auth provider**

Change `web/src/app/layout.tsx` — add `import { Providers } from "./providers";` and wrap children:

```tsx
import type { Metadata } from "next";
import { Providers } from "./providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "UniPark Admin",
  description: "University Parking Management — Admin Dashboard",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <body className="bg-[#111317] text-[#e2e2e8] font-sans antialiased min-h-screen">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

- [ ] **Step 5: Create login page**

Create `web/src/app/(auth)/login/page.tsx`:

```tsx
import { signIn } from "@/lib/auth";
import { redirect } from "next/navigation";

export default function LoginPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="glass-panel rounded-xl p-lg max-w-md w-full mx-4 text-center">
        <h1 className="font-sora text-headline-lg text-primary-fixed-dim mb-2">UniPark</h1>
        <p className="text-on-surface-variant text-body-md mb-md">Admin Dashboard</p>
        <form
          action={async () => {
            "use server";
            await signIn("keycloak", { redirectTo: "/admin/dashboard" });
          }}
        >
          <button
            type="submit"
            className="w-full bg-primary-fixed text-on-primary-fixed font-label-md py-3 px-4 rounded-lg hover:opacity-90 transition-all"
          >
            Sign in with University Account
          </button>
        </form>
        <p className="text-outline text-label-sm mt-sm">@universidad.edu accounts only</p>
      </div>
    </div>
  );
}
```

- [ ] **Step 6: Create route handler for NextAuth**

Create `web/src/app/api/auth/[...nextauth]/route.ts`:

```typescript
import { handlers } from "@/lib/auth";

export const { GET, POST } = handlers;
```

- [ ] **Step 7: Create middleware.ts**

```typescript
import NextAuth from "next-auth";
import { authConfig } from "./lib/auth.config";

export default NextAuth(authConfig).auth;

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico).*)"],
};
```

- [ ] **Step 8: Create .env.local**

Create `web/.env.local`:

```
AUTH_SECRET=change-me-to-random-64-char-string
AUTH_KEYCLOAK_ID=unipark-admin
AUTH_KEYCLOAK_SECRET=change-me
AUTH_KEYCLOAK_ISSUER=http://localhost:8080/realms/unipark
NEXT_PUBLIC_API_URL=http://localhost:8080
```

- [ ] **Step 9: Commit**

```bash
git add web/src/lib/auth.ts web/src/lib/auth.config.ts web/src/app/providers.tsx web/src/app/layout.tsx web/src/app/\(auth\)/ web/src/app/api/ web/src/middleware.ts web/.env.local
git commit -m "feat: add NextAuth.js with Keycloak provider and role-based middleware"
```

---

### Task 12: API Client Library

**Files:**
- Create: `web/src/lib/api.ts`

- [ ] **Step 1: Create api.ts**

```typescript
import { auth } from "./auth";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080";

export async function serverFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const session = await auth();
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(session?.user ? { Authorization: `Bearer ${(session as any).accessToken}` } : {}),
      ...options?.headers,
    },
  });

  if (!res.ok) {
    if (res.status === 403) throw new ForbiddenError();
    throw new ApiError(res.status, await res.text());
  }
  return res.json();
}

export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

export class ForbiddenError extends ApiError {
  constructor() {
    super(403, "Forbidden");
  }
}

export async function clientFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...options?.headers,
    },
    credentials: "include",
  });

  if (!res.ok) {
    if (res.status === 403) throw new ForbiddenError();
    throw new ApiError(res.status, await res.text());
  }
  return res.json();
}
```

- [ ] **Step 2: Commit**

```bash
git add web/src/lib/api.ts
git commit -m "feat: add API client library with server and client fetch helpers"
```

---

### Task 13: Layout Shell — Sidebar + Header

**Files:**
- Create: `web/src/components/layout/Sidebar.tsx`, `web/src/components/layout/Header.tsx`
- Create: `web/src/app/(admin)/layout.tsx`

- [ ] **Step 1: Create Sidebar.tsx**

```tsx
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useSession } from "next-auth/react";

const adminLinks = [
  { href: "/admin/dashboard", icon: "dashboard", label: "Dashboard" },
  { href: "/admin/lots", icon: "directions_car", label: "Lots" },
  { href: "/admin/violations", icon: "gavel", label: "Violations" },
];

const superadminLinks = [
  { href: "/admin/users", icon: "group", label: "Users & Roles" },
  { href: "/admin/audit", icon: "receipt_long", label: "Audit Log" },
  { href: "/admin/settings", icon: "settings", label: "Settings" },
];

export function Sidebar() {
  const pathname = usePathname();
  const { data: session } = useSession();
  const role = (session?.user as any)?.role as string;

  const isActive = (href: string) => pathname === href;

  return (
    <aside className="w-60 h-screen fixed left-0 top-0 bg-surface-container-lowest border-r border-white/5 flex flex-col py-4 px-3 z-40">
      <Link href="/admin/dashboard" className="font-sora text-lg font-bold text-primary-fixed-dim px-3 mb-7">
        UniPark
      </Link>

      <nav className="flex-1">
        <div className="text-outline text-label-sm uppercase tracking-wider px-3 mb-2">Main</div>
        {adminLinks.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className={`flex items-center gap-2.5 px-3 py-2 rounded-lg mb-0.5 text-body-md transition-all ${
              isActive(link.href)
                ? "bg-secondary-fixed/10 text-secondary-fixed"
                : "text-on-surface-variant hover:text-secondary-fixed-dim"
            }`}
          >
            <span className="material-symbols-outlined text-xl">{link.icon}</span>
            <span>{link.label}</span>
          </Link>
        ))}

        {role === "superadmin" && (
          <>
            <div className="text-outline text-label-sm uppercase tracking-wider px-3 mb-2 mt-6">Administration</div>
            {superadminLinks.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className={`flex items-center gap-2.5 px-3 py-2 rounded-lg mb-0.5 text-body-md transition-all ${
                  isActive(link.href)
                    ? "bg-secondary-fixed/10 text-secondary-fixed"
                    : "text-on-surface-variant hover:text-secondary-fixed-dim"
                }`}
              >
                <span className="material-symbols-outlined text-xl">{link.icon}</span>
                <span>{link.label}</span>
              </Link>
            ))}
          </>
        )}
      </nav>

      <div className="border-t border-white/5 pt-3">
        <Link
          href="/api/auth/signout"
          className="flex items-center gap-2.5 px-3 py-2 rounded-lg text-on-surface-variant hover:text-error transition-all"
        >
          <span className="material-symbols-outlined text-xl">logout</span>
          <span>Sign Out</span>
        </Link>
      </div>
    </aside>
  );
}
```

- [ ] **Step 2: Create Header.tsx**

```tsx
"use client";

import { useSession } from "next-auth/react";

export function Header() {
  const { data: session } = useSession();
  const user = session?.user;
  const role = (user as any)?.role as string;

  return (
    <header className="h-14 sticky top-0 z-30 bg-surface-container-lowest/80 backdrop-blur-xl border-b border-white/5 flex items-center justify-end px-6 ml-60">
      <div className="flex items-center gap-3">
        <div className="w-8 h-8 rounded-full bg-surface-container border border-white/10 flex items-center justify-center">
          <span className="material-symbols-outlined text-sm text-outline">person</span>
        </div>
        <div>
          <div className="text-on-background text-body-md font-medium leading-tight">{user?.name || user?.email}</div>
          <div className={`text-label-sm ${role === "superadmin" ? "text-secondary-fixed" : "text-outline"}`}>
            {role}
          </div>
        </div>
      </div>
    </header>
  );
}
```

- [ ] **Step 3: Create admin layout**

```tsx
import { Sidebar } from "@/components/layout/Sidebar";
import { Header } from "@/components/layout/Header";
import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const session = await auth();
  if (!session?.user) redirect("/login");

  return (
    <>
      <Sidebar />
      <div className="ml-60">
        <Header />
        <main className="p-6">{children}</main>
      </div>
    </>
  );
}
```

- [ ] **Step 4: Commit**

```bash
git add web/src/components/layout/ web/src/app/\(admin\)/layout.tsx
git commit -m "feat: add sidebar and header layout shell for admin dashboard"
```

---

### Task 14: Shared UI Components

**Files:**
- Create: `web/src/components/ui/GlassPanel.tsx`, `web/src/components/ui/OccupancyBar.tsx`, `web/src/components/ui/StatusPill.tsx`, `web/src/components/ui/StatusDot.tsx`, `web/src/components/ui/Skeleton.tsx`

- [ ] **Step 1: Create GlassPanel.tsx**

```tsx
import { ReactNode } from "react";

interface GlassPanelProps {
  children: ReactNode;
  className?: string;
  glow?: boolean;
}

export function GlassPanel({ children, className = "", glow = false }: GlassPanelProps) {
  return (
    <div
      className={`bg-surface-container/60 backdrop-blur-xl border-t border-l border-white/10 border-r border-black/20 border-b border-black/20 rounded-xl p-md ${
        glow ? "shadow-[0_0_24px_rgba(54,255,196,0.25)]" : ""
      } ${className}`}
    >
      {children}
    </div>
  );
}
```

- [ ] **Step 2: Create OccupancyBar.tsx**

```tsx
interface OccupancyBarProps {
  used: number;
  total: number;
  className?: string;
}

export function OccupancyBar({ used, total, className = "" }: OccupancyBarProps) {
  const pct = Math.round((used / total) * 100);
  const isCritical = pct > 90;
  const isWarning = pct > 80;

  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <div className="flex-1 h-1.5 bg-surface-variant rounded-full overflow-hidden">
        <div
          className={`h-full rounded-full ${
            isCritical
              ? "bg-error shadow-[0_0_8px_rgba(255,180,171,0.6)]"
              : isWarning
                ? "bg-primary-fixed-dim shadow-[0_0_8px_rgba(0,219,233,0.4)]"
                : "bg-secondary-fixed shadow-[0_0_8px_rgba(54,255,196,0.6)]"
          }`}
          style={{ width: `${pct}%` }}
        />
      </div>
      <span className={`font-mono-data text-label-sm ${isCritical ? "text-error" : "text-secondary-fixed"}`}>
        {pct}%
      </span>
    </div>
  );
}
```

- [ ] **Step 3: Create StatusPill.tsx**

```tsx
type StatusColor = "green" | "cyan" | "purple" | "red" | "gray";

const colorMap: Record<StatusColor, { bg: string; text: string }> = {
  green: { bg: "bg-secondary-fixed/10", text: "text-secondary-fixed" },
  cyan: { bg: "bg-primary-fixed/10", text: "text-primary-fixed-dim" },
  purple: { bg: "bg-tertiary-fixed-dim/10", text: "text-tertiary-fixed-dim" },
  red: { bg: "bg-error/10", text: "text-error" },
  gray: { bg: "bg-surface-variant/30", text: "text-outline" },
};

interface StatusPillProps {
  label: string;
  color?: StatusColor;
}

export function StatusPill({ label, color = "gray" }: StatusPillProps) {
  const c = colorMap[color];
  return (
    <span className={`inline-block px-2 py-0.5 rounded text-label-sm ${c.bg} ${c.text}`}>
      {label}
    </span>
  );
}
```

- [ ] **Step 4: Create StatusDot.tsx**

```tsx
interface StatusDotProps {
  active: boolean;
}

export function StatusDot({ active }: StatusDotProps) {
  return (
    <span
      className={`inline-block w-2 h-2 rounded-full ${
        active
          ? "bg-secondary-fixed shadow-[0_0_8px_rgba(54,255,196,0.8)]"
          : "bg-outline"
      }`}
    />
  );
}
```

- [ ] **Step 5: Create Skeleton.tsx**

```tsx
interface SkeletonProps {
  className?: string;
}

export function Skeleton({ className = "" }: SkeletonProps) {
  return (
    <div
      className={`relative overflow-hidden bg-surface-container rounded-lg ${className}`}
    >
      <div className="absolute inset-0 shimmer-effect" />
    </div>
  );
}

export function CardSkeleton() {
  return (
    <div className="glass-panel rounded-xl p-md space-y-3">
      <Skeleton className="h-4 w-24" />
      <Skeleton className="h-8 w-32" />
      <Skeleton className="h-2 w-full" />
    </div>
  );
}
```

- [ ] **Step 6: Commit**

```bash
git add web/src/components/ui/
git commit -m "feat: add shared UI components — GlassPanel, OccupancyBar, StatusPill, StatusDot, Skeleton"
```

---

### Task 15: Dashboard Page

**Files:**
- Create: `web/src/app/(admin)/page.tsx`, `web/src/app/(admin)/dashboard/page.tsx`

- [ ] **Step 1: Create root admin redirect**

`web/src/app/(admin)/page.tsx`:
```tsx
import { redirect } from "next/navigation";

export default function AdminPage() {
  redirect("/admin/dashboard");
}
```

- [ ] **Step 2: Create DashboardPage**

`web/src/app/(admin)/dashboard/page.tsx`:
```tsx
import { GlassPanel } from "@/components/ui/GlassPanel";
import { OccupancyBar } from "@/components/ui/OccupancyBar";
import { serverFetch } from "@/lib/api";

interface AdminStats {
  lots: { name: string; capacityTotal: number; capacityUsed: number }[];
  todayScans: number;
  pendingViolations: number;
  totalUsers: number;
}

export const dynamic = "force-dynamic";
export const revalidate = 30;

export default async function DashboardPage() {
  const stats = await serverFetch<AdminStats>("/v1/admin/stats").catch(() => ({
    lots: [],
    todayScans: 0,
    pendingViolations: 0,
    totalUsers: 0,
  }));

  return (
    <div>
      <h1 className="font-sora text-headline-lg text-on-background mb-6">Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        <GlassPanel>
          <div className="flex items-center gap-2 mb-1">
            <span className="material-symbols-outlined text-secondary-fixed text-sm">verified</span>
            <h2 className="font-label-md text-secondary-fixed uppercase tracking-wider">Occupancy Overview</h2>
          </div>
          <div className="text-display-lg font-bold font-sora text-on-background mt-2 mb-4">
            {stats.lots.length} <span className="text-body-md text-on-surface-variant font-normal">lots</span>
          </div>
          <div className="space-y-3">
            {stats.lots.map((lot) => (
              <div key={lot.name}>
                <div className="flex justify-between text-label-sm mb-1">
                  <span className="text-on-background">{lot.name}</span>
                </div>
                <OccupancyBar used={lot.capacityUsed} total={lot.capacityTotal} />
              </div>
            ))}
          </div>
        </GlassPanel>

        <GlassPanel>
          <div className="flex items-center gap-2 mb-1">
            <span className="material-symbols-outlined text-primary-fixed-dim text-sm">bar_chart</span>
            <h2 className="font-label-md text-primary-fixed-dim uppercase tracking-wider">Today's Activity</h2>
          </div>
          <div className="grid grid-cols-2 gap-4 mt-4">
            <div>
              <div className="text-display-lg font-bold font-sora text-on-background">{stats.todayScans}</div>
              <div className="text-label-sm text-outline">Scans</div>
            </div>
            <div>
              <div className="text-display-lg font-bold font-sora text-error">{stats.pendingViolations}</div>
              <div className="text-label-sm text-outline">Pending Violations</div>
            </div>
            <div className="col-span-2">
              <div className="text-display-lg font-bold font-sora text-on-background">{stats.totalUsers}</div>
              <div className="text-label-sm text-outline">Total Users</div>
            </div>
          </div>
        </GlassPanel>
      </div>
    </div>
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add web/src/app/\(admin\)/page.tsx web/src/app/\(admin\)/dashboard/
git commit -m "feat: add admin dashboard page with occupancy and activity stats"
```

---

### Task 16: Users & Roles Page

**Files:**
- Create: `web/src/app/(admin)/(superadmin)/users/page.tsx`
- Create: `web/src/components/shared/ConfirmDialog.tsx`
- Create: `web/src/components/shared/Toast.tsx`

- [ ] **Step 1: Create Toast.tsx**

```tsx
"use client";

import { useEffect, useState } from "react";

interface ToastData {
  message: string;
  type: "success" | "error";
}

let toastListeners: ((data: ToastData) => void)[] = [];

export function showToast(message: string, type: "success" | "error" = "success") {
  toastListeners.forEach((fn) => fn({ message, type }));
}

export function Toast() {
  const [toast, setToast] = useState<ToastData | null>(null);

  useEffect(() => {
    toastListeners.push(setToast);
    return () => {
      toastListeners = toastListeners.filter((fn) => fn !== setToast);
    };
  }, []);

  useEffect(() => {
    if (toast) {
      const timer = setTimeout(() => setToast(null), 4000);
      return () => clearTimeout(timer);
    }
  }, [toast]);

  if (!toast) return null;

  return (
    <div
      className={`fixed bottom-6 right-6 z-50 px-4 py-3 rounded-lg text-body-md font-medium shadow-lg transition-all ${
        toast.type === "success"
          ? "bg-secondary-container/20 text-secondary-fixed border border-secondary-fixed/30"
          : "bg-error-container/20 text-error border border-error/30"
      }`}
    >
      {toast.message}
    </div>
  );
}
```

- [ ] **Step 2: Create ConfirmDialog.tsx**

```tsx
"use client";

interface ConfirmDialogProps {
  open: boolean;
  title: string;
  message: string;
  confirmLabel?: string;
  onConfirm: () => void;
  onCancel: () => void;
}

export function ConfirmDialog({ open, title, message, confirmLabel = "Confirm", onConfirm, onCancel }: ConfirmDialogProps) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onCancel} />
      <div className="relative bg-surface-container-high border border-white/10 rounded-xl p-6 max-w-sm w-full mx-4 shadow-2xl">
        <h3 className="font-sora text-headline-md text-on-background mb-2">{title}</h3>
        <p className="text-on-surface-variant text-body-md mb-6">{message}</p>
        <div className="flex gap-3 justify-end">
          <button
            onClick={onCancel}
            className="px-4 py-2 rounded-lg text-on-surface-variant hover:text-on-background transition-all"
          >
            Cancel
          </button>
          <button
            onClick={onConfirm}
            className="px-4 py-2 rounded-lg bg-secondary-fixed text-on-secondary-fixed font-label-md hover:opacity-90 transition-all"
          >
            {confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 3: Create UsersPage**

`web/src/app/(admin)/(superadmin)/users/page.tsx`:
```tsx
"use client";

import { useState } from "react";
import useSWR from "swr";
import { GlassPanel } from "@/components/ui/GlassPanel";
import { StatusPill } from "@/components/ui/StatusPill";
import { StatusDot } from "@/components/ui/StatusDot";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Toast, showToast } from "@/components/shared/Toast";
import { clientFetch } from "@/lib/api";

interface UserSummary {
  id: string;
  email: string;
  fullName: string;
  role: string;
  universityId: string;
  active: boolean;
  createdAt: string;
}

interface PageResponse<T> {
  content: T[];
  totalPages: number;
  totalElements: number;
  number: number;
}

const roleColor = (role: string) => {
  switch (role) {
    case "superadmin": return "green" as const;
    case "admin": return "cyan" as const;
    case "guard": return "purple" as const;
    default: return "gray" as const;
  }
};

const fetcher = (url: string) => clientFetch<PageResponse<UserSummary>>(url);

export default function UsersPage() {
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [page, setPage] = useState(0);
  const [editingUser, setEditingUser] = useState<UserSummary | null>(null);
  const [newRole, setNewRole] = useState("");
  const [confirmOpen, setConfirmOpen] = useState(false);

  const params = new URLSearchParams({ page: String(page), size: "20" });
  if (search) params.set("search", search);
  if (roleFilter) params.set("role", roleFilter);

  const { data, error, isLoading, mutate } = useSWR(`/v1/admin/users?${params}`, fetcher);

  const handleRoleChange = (user: UserSummary, role: string) => {
    setEditingUser(user);
    setNewRole(role);
    setConfirmOpen(true);
  };

  const confirmRoleChange = async () => {
    if (!editingUser) return;
    try {
      await clientFetch(`/v1/admin/users/${editingUser.id}`, {
        method: "PATCH",
        body: JSON.stringify({ role: newRole }),
      });
      mutate();
      showToast(`Changed ${editingUser.fullName}'s role to ${newRole}`, "success");
    } catch {
      showToast("Failed to update role", "error");
    }
    setConfirmOpen(false);
    setEditingUser(null);
  };

  return (
    <div>
      <h1 className="font-sora text-headline-lg text-on-background mb-6">Users & Roles</h1>

      <GlassPanel>
        <div className="flex gap-3 mb-4">
          <input
            type="text"
            placeholder="Search by name, email, or university ID..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(0); }}
            className="flex-1 bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background text-body-md placeholder:text-outline focus:outline-none focus:border-secondary-fixed/50"
          />
          <select
            value={roleFilter}
            onChange={(e) => { setRoleFilter(e.target.value); setPage(0); }}
            className="bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background text-body-md focus:outline-none"
          >
            <option value="">All Roles</option>
            <option value="driver">Driver</option>
            <option value="guard">Guard</option>
            <option value="admin">Admin</option>
            <option value="superadmin">Superadmin</option>
          </select>
        </div>

        {isLoading && <div className="text-on-surface-variant py-8 text-center">Loading...</div>}
        {error && <div className="text-error py-8 text-center">Failed to load users</div>}

        {data && (
          <>
            <table className="w-full border-collapse">
              <thead>
                <tr className="border-b border-white/5">
                  <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">User</th>
                  <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">Email</th>
                  <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">Role</th>
                  <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">Status</th>
                </tr>
              </thead>
              <tbody>
                {data.content.map((user) => (
                  <tr key={user.id} className="border-b border-white/[0.02] hover:bg-surface-container/30 transition-colors">
                    <td className="py-2.5 px-2">
                      <div className="text-on-background text-body-md">{user.fullName}</div>
                      <div className="text-outline text-label-sm">{user.universityId}</div>
                    </td>
                    <td className="py-2.5 px-2 text-on-surface-variant text-body-md">{user.email}</td>
                    <td className="py-2.5 px-2">
                      <select
                        value={user.role}
                        onChange={(e) => handleRoleChange(user, e.target.value)}
                        className="bg-transparent border-none text-body-md cursor-pointer focus:outline-none"
                        style={{ color: "inherit" }}
                      >
                        <option value="driver">Driver</option>
                        <option value="guard">Guard</option>
                        <option value="admin">Admin</option>
                        <option value="superadmin">Superadmin</option>
                      </select>
                    </td>
                    <td className="py-2.5 px-2">
                      <StatusDot active={user.active} />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>

            {data.totalPages > 1 && (
              <div className="flex justify-between items-center mt-4 pt-3 border-t border-white/5">
                <span className="text-outline text-label-sm">
                  {data.totalElements} users
                </span>
                <div className="flex gap-2">
                  <button
                    onClick={() => setPage(Math.max(0, page - 1))}
                    disabled={page === 0}
                    className="px-3 py-1 rounded text-body-md text-on-surface-variant hover:text-on-background disabled:opacity-30 transition-all"
                  >
                    Previous
                  </button>
                  <button
                    onClick={() => setPage(Math.min(data.totalPages - 1, page + 1))}
                    disabled={page >= data.totalPages - 1}
                    className="px-3 py-1 rounded text-body-md text-on-surface-variant hover:text-on-background disabled:opacity-30 transition-all"
                  >
                    Next
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </GlassPanel>

      <ConfirmDialog
        open={confirmOpen}
        title="Change User Role"
        message={`Set ${editingUser?.fullName}'s role to "${newRole}"?`}
        confirmLabel="Change Role"
        onConfirm={confirmRoleChange}
        onCancel={() => { setConfirmOpen(false); setEditingUser(null); }}
      />

      <Toast />
    </div>
  );
}
```

- [ ] **Step 4: Commit**

```bash
git add web/src/app/\(admin\)/\(superadmin\)/users/ web/src/components/shared/ConfirmDialog.tsx web/src/components/shared/Toast.tsx
git commit -m "feat: add users & roles page with search, role editing, and confirmation"
```

---

### Task 17: Lots Page

**Files:**
- Create: `web/src/app/(admin)/lots/page.tsx`

- [ ] **Step 1: Create LotsPage**

```tsx
"use client";

import { useState } from "react";
import useSWR from "swr";
import { GlassPanel } from "@/components/ui/GlassPanel";
import { OccupancyBar } from "@/components/ui/OccupancyBar";
import { StatusPill } from "@/components/ui/StatusPill";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Toast, showToast } from "@/components/shared/Toast";
import { clientFetch } from "@/lib/api";

interface Lot {
  id: string;
  name: string;
  capacityTotal: number;
  capacityUsed: number;
  active: boolean;
}

const fetcher = (url: string) => clientFetch<Lot[]>(url);

export default function LotsPage() {
  const { data, isLoading, mutate } = useSWR("/v1/lots", fetcher);
  const [showNewModal, setShowNewModal] = useState(false);
  const [newName, setNewName] = useState("");
  const [newCapacity, setNewCapacity] = useState("");

  const createLot = async () => {
    try {
      await clientFetch("/v1/lots", {
        method: "POST",
        body: JSON.stringify({ name: newName, capacityTotal: parseInt(newCapacity) }),
      });
      mutate();
      setShowNewModal(false);
      setNewName("");
      setNewCapacity("");
      showToast("Lot created", "success");
    } catch {
      showToast("Failed to create lot", "error");
    }
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="font-sora text-headline-lg text-on-background">Parking Lots</h1>
        <button
          onClick={() => setShowNewModal(true)}
          className="flex items-center gap-1.5 bg-secondary-fixed text-on-secondary-fixed font-label-md px-4 py-2 rounded-lg hover:opacity-90 transition-all"
        >
          <span className="material-symbols-outlined text-sm">add</span>
          New Lot
        </button>
      </div>

      <GlassPanel>
        {isLoading && <div className="text-on-surface-variant py-8 text-center">Loading...</div>}

        {data && (
          <table className="w-full border-collapse">
            <thead>
              <tr className="border-b border-white/5">
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Name</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Capacity</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Used</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Occupancy</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Status</th>
              </tr>
            </thead>
            <tbody>
              {data.map((lot) => (
                <tr key={lot.id} className="border-b border-white/[0.02] hover:bg-surface-container/30 transition-colors">
                  <td className="py-3 px-3 text-on-background text-body-md font-medium">{lot.name}</td>
                  <td className="py-3 px-3 text-on-surface-variant text-body-md">{lot.capacityTotal}</td>
                  <td className="py-3 px-3 text-on-surface-variant text-body-md">{lot.capacityUsed}</td>
                  <td className="py-3 px-3 min-w-[180px]">
                    <OccupancyBar used={lot.capacityUsed} total={lot.capacityTotal} />
                  </td>
                  <td className="py-3 px-3">
                    <StatusPill
                      label={lot.active ? "Active" : "Inactive"}
                      color={lot.active ? "green" : "gray"}
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </GlassPanel>

      {showNewModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setShowNewModal(false)} />
          <div className="relative bg-surface-container-high border border-white/10 rounded-xl p-6 max-w-sm w-full mx-4 shadow-2xl">
            <h3 className="font-sora text-headline-md text-on-background mb-4">New Parking Lot</h3>
            <input
              type="text"
              placeholder="Lot name"
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background mb-3 focus:outline-none focus:border-secondary-fixed/50"
            />
            <input
              type="number"
              placeholder="Total capacity"
              value={newCapacity}
              onChange={(e) => setNewCapacity(e.target.value)}
              className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background mb-4 focus:outline-none focus:border-secondary-fixed/50"
            />
            <div className="flex gap-3 justify-end">
              <button onClick={() => setShowNewModal(false)} className="px-4 py-2 rounded-lg text-on-surface-variant hover:text-on-background">Cancel</button>
              <button onClick={createLot} className="px-4 py-2 rounded-lg bg-secondary-fixed text-on-secondary-fixed font-label-md hover:opacity-90">Create</button>
            </div>
          </div>
        </div>
      )}

      <Toast />
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add web/src/app/\(admin\)/lots/
git commit -m "feat: add parking lots management page with create modal"
```

---

### Task 18: Violations Page

**Files:**
- Create: `web/src/app/(admin)/violations/page.tsx`

- [ ] **Step 1: Create ViolationsPage**

```tsx
"use client";

import { useState } from "react";
import useSWR from "swr";
import { GlassPanel } from "@/components/ui/GlassPanel";
import { StatusPill } from "@/components/ui/StatusPill";
import { Toast, showToast } from "@/components/shared/Toast";
import { clientFetch } from "@/lib/api";

interface ViolationSummary {
  id: string;
  vehiclePlate: string | null;
  guardName: string;
  lotName: string | null;
  reason: string;
  status: string;
  evidenceUrl: string | null;
  createdAt: string;
}

interface PageResponse<T> {
  content: T[];
  totalPages: number;
  totalElements: number;
  number: number;
}

const fetcher = (url: string) => clientFetch<PageResponse<ViolationSummary>>(url);

export default function ViolationsPage() {
  const [statusFilter, setStatusFilter] = useState("");
  const [page, setPage] = useState(0);
  const [selected, setSelected] = useState<ViolationSummary | null>(null);
  const [note, setNote] = useState("");

  const params = new URLSearchParams({ page: String(page), size: "20" });
  if (statusFilter) params.set("status", statusFilter);

  const { data, isLoading, mutate } = useSWR(`/v1/admin/violations?${params}`, fetcher);

  const resolveViolation = async (id: string, status: string) => {
    try {
      await clientFetch(`/v1/admin/violations/${id}`, {
        method: "PATCH",
        body: JSON.stringify({ status, resolutionNote: note }),
      });
      mutate();
      setSelected(null);
      setNote("");
      showToast(`Violation ${status.toLowerCase()}`, "success");
    } catch {
      showToast("Failed to resolve violation", "error");
    }
  };

  return (
    <div>
      <h1 className="font-sora text-headline-lg text-on-background mb-6">Violations</h1>

      <GlassPanel>
        <div className="flex gap-2 mb-4">
          {["", "PENDING", "APPROVED", "DISMISSED"].map((s) => (
            <button
              key={s}
              onClick={() => { setStatusFilter(s); setPage(0); }}
              className={`px-3 py-1.5 rounded-lg text-label-md transition-all ${
                statusFilter === s
                  ? "bg-secondary-fixed/10 text-secondary-fixed"
                  : "text-on-surface-variant hover:text-on-background"
              }`}
            >
              {s || "All"}
            </button>
          ))}
        </div>

        {isLoading && <div className="text-on-surface-variant py-8 text-center">Loading...</div>}

        {data && data.content.length === 0 && (
          <div className="text-on-surface-variant py-12 text-center">
            <span className="material-symbols-outlined text-4xl block mb-2">check_circle</span>
            No violations found
          </div>
        )}

        {data && data.content.length > 0 && (
          <table className="w-full border-collapse">
            <thead>
              <tr className="border-b border-white/5">
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Vehicle</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Guard</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Reason</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Status</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Date</th>
              </tr>
            </thead>
            <tbody>
              {data.content.map((v) => (
                <tr
                  key={v.id}
                  onClick={() => setSelected(v)}
                  className="border-b border-white/[0.02] hover:bg-surface-container/30 transition-colors cursor-pointer"
                >
                  <td className="py-2.5 px-3 text-on-background font-mono-data">{v.vehiclePlate || "—"}</td>
                  <td className="py-2.5 px-3 text-on-surface-variant text-body-md">{v.guardName}</td>
                  <td className="py-2.5 px-3 text-on-surface-variant text-body-md max-w-60 truncate">{v.reason}</td>
                  <td className="py-2.5 px-3">
                    <StatusPill
                      label={v.status}
                      color={v.status === "PENDING" ? "red" : v.status === "APPROVED" ? "green" : "gray"}
                    />
                  </td>
                  <td className="py-2.5 px-3 text-outline text-label-sm">
                    {new Date(v.createdAt).toLocaleDateString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </GlassPanel>

      {selected && (
        <div className="fixed inset-y-0 right-0 z-50 w-96 max-w-full bg-surface-container-high border-l border-white/10 shadow-2xl overflow-y-auto">
          <div className="p-6">
            <div className="flex justify-between items-center mb-4">
              <h2 className="font-sora text-headline-md text-on-background">Violation Detail</h2>
              <button onClick={() => setSelected(null)} className="text-outline hover:text-on-background">
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>

            <div className="space-y-4 text-body-md">
              <div><span className="text-outline">Vehicle:</span> <span className="text-on-background font-mono-data">{selected.vehiclePlate || "Unknown"}</span></div>
              <div><span className="text-outline">Guard:</span> <span className="text-on-background">{selected.guardName}</span></div>
              <div><span className="text-outline">Lot:</span> <span className="text-on-background">{selected.lotName || "Unknown"}</span></div>
              <div><span className="text-outline">Reason:</span> <span className="text-on-background">{selected.reason}</span></div>
              <div><span className="text-outline">Status:</span> <StatusPill label={selected.status} color={selected.status === "PENDING" ? "red" : selected.status === "APPROVED" ? "green" : "gray"} /></div>
            </div>

            {selected.evidenceUrl && (
              <img src={selected.evidenceUrl} alt="Evidence" className="mt-4 rounded-lg border border-white/10 w-full" />
            )}

            {selected.status === "PENDING" && (
              <div className="mt-6 space-y-3">
                <textarea
                  placeholder="Resolution note (required)..."
                  value={note}
                  onChange={(e) => setNote(e.target.value)}
                  className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background resize-none h-24 focus:outline-none focus:border-secondary-fixed/50"
                />
                <div className="flex gap-2">
                  <button
                    onClick={() => resolveViolation(selected.id, "APPROVED")}
                    className="flex-1 bg-secondary-fixed text-on-secondary-fixed font-label-md py-2 rounded-lg hover:opacity-90"
                  >
                    Approve
                  </button>
                  <button
                    onClick={() => resolveViolation(selected.id, "DISMISSED")}
                    className="flex-1 bg-error/20 text-error font-label-md py-2 rounded-lg hover:bg-error/30"
                  >
                    Dismiss
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      <Toast />
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add web/src/app/\(admin\)/violations/
git commit -m "feat: add violations console with filterable list and detail drawer"
```

---

### Task 19: Audit Log Page

**Files:**
- Create: `web/src/app/(admin)/(superadmin)/audit/page.tsx`

- [ ] **Step 1: Create AuditPage**

```tsx
"use client";

import { useState } from "react";
import useSWR from "swr";
import { GlassPanel } from "@/components/ui/GlassPanel";
import { clientFetch } from "@/lib/api";

interface AuditEntry {
  id: number;
  actorId: string | null;
  action: string;
  targetId: string | null;
  payload: Record<string, any> | null;
  ip: string | null;
  createdAt: string;
}

interface PageResponse<T> {
  content: T[];
  totalPages: number;
  totalElements: number;
  number: number;
}

const fetcher = (url: string) => clientFetch<PageResponse<AuditEntry>>(url);

export default function AuditPage() {
  const [page, setPage] = useState(0);
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [actionFilter, setActionFilter] = useState("");
  const [expanded, setExpanded] = useState<number | null>(null);

  const params = new URLSearchParams({ page: String(page), size: "50" });
  if (from) params.set("from", new Date(from).toISOString());
  if (to) params.set("to", new Date(to).toISOString());
  if (actionFilter) params.set("action", actionFilter);

  const { data, isLoading } = useSWR(`/v1/admin/audit?${params}`, fetcher);

  return (
    <div>
      <h1 className="font-sora text-headline-lg text-on-background mb-6">Audit Log</h1>

      <GlassPanel>
        <div className="flex flex-wrap gap-3 mb-4">
          <input
            type="date"
            value={from}
            onChange={(e) => { setFrom(e.target.value); setPage(0); }}
            className="bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background text-body-md focus:outline-none focus:border-secondary-fixed/50"
          />
          <input
            type="date"
            value={to}
            onChange={(e) => { setTo(e.target.value); setPage(0); }}
            className="bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background text-body-md focus:outline-none focus:border-secondary-fixed/50"
          />
          <input
            type="text"
            value={actionFilter}
            onChange={(e) => { setActionFilter(e.target.value); setPage(0); }}
            placeholder="Filter by action..."
            className="bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background text-body-md placeholder:text-outline focus:outline-none focus:border-secondary-fixed/50"
          />
        </div>

        {isLoading && <div className="text-on-surface-variant py-8 text-center">Loading...</div>}

        {data && (
          <table className="w-full border-collapse">
            <thead>
              <tr className="border-b border-white/5">
                <th className="text-left py-2 px-2 text-outline text-label-sm font-medium w-40">Timestamp</th>
                <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">Action</th>
                <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">Actor</th>
                <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">IP</th>
              </tr>
            </thead>
            <tbody>
              {data.content.map((entry) => (
                <>
                  <tr
                    key={entry.id}
                    onClick={() => setExpanded(expanded === entry.id ? null : entry.id)}
                    className="border-b border-white/[0.02] hover:bg-surface-container/30 transition-colors cursor-pointer"
                  >
                    <td className="py-2 px-2 text-outline text-label-sm font-mono">{new Date(entry.createdAt).toLocaleString()}</td>
                    <td className="py-2 px-2 text-on-background text-body-md">{entry.action}</td>
                    <td className="py-2 px-2 text-on-surface-variant text-body-md font-mono text-xs">{entry.actorId || "—"}</td>
                    <td className="py-2 px-2 text-outline text-label-sm">{entry.ip || "—"}</td>
                  </tr>
                  {expanded === entry.id && (
                    <tr key={`${entry.id}-expanded`}>
                      <td colSpan={4} className="py-3 px-4 bg-surface-container/20">
                        <div className="text-outline text-label-sm mb-1">Payload</div>
                        <pre className="text-on-surface-variant text-body-md font-mono text-xs whitespace-pre-wrap">
                          {JSON.stringify(entry.payload, null, 2) || "—"}
                        </pre>
                      </td>
                    </tr>
                  )}
                </>
              ))}
            </tbody>
          </table>
        )}
      </GlassPanel>
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add web/src/app/\(admin\)/\(superadmin\)/audit/
git commit -m "feat: add audit log page with date filters and expandable payload rows"
```

---

### Task 20: Settings Page

**Files:**
- Create: `web/src/app/(admin)/(superadmin)/settings/page.tsx`

- [ ] **Step 1: Create SettingsPage**

```tsx
"use client";

import { useState } from "react";
import useSWR from "swr";
import { GlassPanel } from "@/components/ui/GlassPanel";
import { Toast, showToast } from "@/components/shared/Toast";
import { clientFetch } from "@/lib/api";

interface SystemSettings {
  occupancyWarningPercent: number;
  occupancyCriticalPercent: number;
  rateLimitRequests: number;
  rateLimitWindowSeconds: number;
  qrExpirySeconds: number;
  maintenanceMode: boolean;
}

const fetcher = (url: string) => clientFetch<SystemSettings>(url);

export default function SettingsPage() {
  const { data, isLoading, mutate } = useSWR("/v1/admin/settings", fetcher);
  const [saving, setSaving] = useState<string | null>(null);

  const save = async (key: string, body: Record<string, any>) => {
    setSaving(key);
    try {
      await clientFetch("/v1/admin/settings", { method: "PATCH", body: JSON.stringify(body) });
      mutate();
      showToast("Settings updated", "success");
    } catch {
      showToast("Failed to save settings", "error");
    }
    setSaving(null);
  };

  if (isLoading) return <div className="text-on-surface-variant py-8 text-center">Loading...</div>;
  if (!data) return null;

  return (
    <div>
      <h1 className="font-sora text-headline-lg text-on-background mb-6">Settings</h1>

      <div className="space-y-4 max-w-2xl">
        <GlassPanel>
          <h2 className="font-sora text-headline-md text-on-background mb-4">Occupancy Thresholds</h2>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-outline text-label-sm block mb-1">Warning (%)</label>
              <input
                type="number"
                defaultValue={data.occupancyWarningPercent}
                id="warningPct"
                className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background focus:outline-none focus:border-secondary-fixed/50"
              />
            </div>
            <div>
              <label className="text-outline text-label-sm block mb-1">Critical (%)</label>
              <input
                type="number"
                defaultValue={data.occupancyCriticalPercent}
                id="criticalPct"
                className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background focus:outline-none focus:border-secondary-fixed/50"
              />
            </div>
          </div>
          <button
            onClick={() => save("occupancy", {
              occupancyWarningPercent: parseInt((document.getElementById("warningPct") as HTMLInputElement).value),
              occupancyCriticalPercent: parseInt((document.getElementById("criticalPct") as HTMLInputElement).value),
            })}
            disabled={saving === "occupancy"}
            className="mt-4 px-4 py-2 rounded-lg bg-secondary-fixed text-on-secondary-fixed font-label-md hover:opacity-90 disabled:opacity-50"
          >
            {saving === "occupancy" ? "Saving..." : "Save Thresholds"}
          </button>
        </GlassPanel>

        <GlassPanel>
          <h2 className="font-sora text-headline-md text-on-background mb-4">Rate Limiting</h2>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-outline text-label-sm block mb-1">Requests per window</label>
              <input
                type="number"
                defaultValue={data.rateLimitRequests}
                id="rlRequests"
                className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background focus:outline-none focus:border-secondary-fixed/50"
              />
            </div>
            <div>
              <label className="text-outline text-label-sm block mb-1">Window (seconds)</label>
              <input
                type="number"
                defaultValue={data.rateLimitWindowSeconds}
                id="rlWindow"
                className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background focus:outline-none focus:border-secondary-fixed/50"
              />
            </div>
          </div>
          <button
            onClick={() => save("ratelimit", {
              rateLimitRequests: parseInt((document.getElementById("rlRequests") as HTMLInputElement).value),
              rateLimitWindowSeconds: parseInt((document.getElementById("rlWindow") as HTMLInputElement).value),
            })}
            disabled={saving === "ratelimit"}
            className="mt-4 px-4 py-2 rounded-lg bg-secondary-fixed text-on-secondary-fixed font-label-md hover:opacity-90 disabled:opacity-50"
          >
            {saving === "ratelimit" ? "Saving..." : "Save Rate Limits"}
          </button>
        </GlassPanel>

        <GlassPanel>
          <h2 className="font-sora text-headline-md text-on-background mb-4">QR Pass</h2>
          <div>
            <label className="text-outline text-label-sm block mb-1">Expiry (seconds)</label>
            <input
              type="number"
              defaultValue={data.qrExpirySeconds}
              id="qrExpiry"
              className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background focus:outline-none focus:border-secondary-fixed/50"
            />
          </div>
          <button
            onClick={() => save("qr", {
              qrExpirySeconds: parseInt((document.getElementById("qrExpiry") as HTMLInputElement).value),
            })}
            disabled={saving === "qr"}
            className="mt-4 px-4 py-2 rounded-lg bg-secondary-fixed text-on-secondary-fixed font-label-md hover:opacity-90 disabled:opacity-50"
          >
            {saving === "qr" ? "Saving..." : "Save QR Expiry"}
          </button>
        </GlassPanel>

        <GlassPanel>
          <h2 className="font-sora text-headline-md text-on-background mb-4">Maintenance Mode</h2>
          <div className="flex items-center gap-3">
            <button
              onClick={() => save("maintenance", { maintenanceMode: !data.maintenanceMode })}
              className={`relative w-12 h-6 rounded-full transition-colors ${
                data.maintenanceMode ? "bg-error" : "bg-surface-variant"
              }`}
            >
              <div className={`absolute top-0.5 w-5 h-5 bg-white rounded-full transition-transform ${
                data.maintenanceMode ? "translate-x-6" : "translate-x-0.5"
              }`} />
            </button>
            <span className="text-on-background text-body-md">
              {data.maintenanceMode ? "Maintenance mode is ON" : "Maintenance mode is OFF"}
            </span>
          </div>
        </GlassPanel>
      </div>

      <Toast />
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add web/src/app/\(admin\)/\(superadmin\)/settings/
git commit -m "feat: add settings page with occupancy, rate limiting, QR, and maintenance mode toggles"
```

---

### Task 21: Verify Build

- [ ] **Step 1: Build the Next.js app**

```bash
cd web && npm run build
```

Expected: successful production build with no TypeScript errors.

- [ ] **Step 2: Commit any final fixes**

```bash
git add -A && git diff --cached --stat
git commit -m "chore: final build fixes and adjustments"
```

---

## Self-Review Checklist

After implementing, verify:

1. **Spec coverage:** All 6 pages implemented. All 8 API endpoints created. Auth flow wired up. Design tokens applied.
2. **Type consistency:** `UserSummary`, `AdminStats`, `ViolationSummary`, `AuditEntry`, `SystemSettings` DTOs match between backend and frontend types.
3. **Security:** All admin endpoints gated with `@PreAuthorize`. Next.js middleware gates superadmin routes. Backend double-defends.
4. **Edge states:** Loading spinners, empty states ("No violations found"), error toasts with retry, 403 handling.
