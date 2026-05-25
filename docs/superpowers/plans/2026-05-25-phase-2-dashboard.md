# Phase 2 — Dashboard Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Dashboard tab with ActivePermitCard (hero, glow-active), CurrentLocationCard, CampusTrendsCard, and SystemAlertsCard, driven by a fake-data ViewModel with staggered entrance animations.

**Architecture:** MVVM with fake in-memory data. DashboardViewModel exposes StateFlow properties consumed by the DashboardScreen. No domain/data layers yet — those come in Phase 6. Cards use existing GlassPanel/GlowActivePanel from Phase 1.

**Tech Stack:** Kotlin 2.0, Jetpack Compose (BOM 2024.12), Material3, Hilt, Hilt Navigation Compose

---

## File Structure Map (new and modified)

```
unipark/android/app/src/main/java/com/unipark/android/
├── domain/
│   └── model/
│       └── DashboardModels.kt          (NEW — data classes)
├── presentation/
│   └── dashboard/
│       ├── DashboardScreen.kt          (MODIFY — replace placeholder)
│       ├── DashboardViewModel.kt       (NEW — fake data VM)
│       └── components/
│           ├── ActivePermitCard.kt     (NEW)
│           ├── CurrentLocationCard.kt  (NEW)
│           ├── CampusTrendsCard.kt     (NEW)
│           └── SystemAlertsCard.kt     (NEW)
└── core/
    └── navigation/
        └── NavGraph.kt                 (MODIFY — wire real screen)
```

---

### Task 1: Dashboard data models

**Files:**
- Create: `android/app/src/main/java/com/unipark/android/domain/model/DashboardModels.kt`

- [ ] **Step 1: Create domain/model directories**

```bash
mkdir -p /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark/android/app/src/main/java/com/unipark/android/domain/model
```

- [ ] **Step 2: Write DashboardModels.kt**

```kotlin
package com.unipark.android.domain.model

import androidx.compose.ui.graphics.vector.ImageVector

data class PermitInfo(
    val permitName: String,
    val status: String,
    val validUntil: String,
    val vehiclePlate: String,
)

data class LocationInfo(
    val lotName: String,
    val spotNumber: String,
    val parkedSince: String,
)

data class OccupancyData(
    val lotName: String,
    val percentage: Int,
)

data class AlertItem(
    val title: String,
    val body: String,
    val timestamp: String,
    val type: AlertType,
)

enum class AlertType {
    Info,
    Warning,
    Maintenance,
}
```

- [ ] **Step 3: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/domain/
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: add Dashboard data models"
```

---

### Task 2: DashboardViewModel with fake data

**Files:**
- Create: `android/app/src/main/java/com/unipark/android/presentation/dashboard/DashboardViewModel.kt`

- [ ] **Step 1: Write DashboardViewModel.kt**

```kotlin
package com.unipark.android.presentation.dashboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.unipark.android.domain.model.AlertItem
import com.unipark.android.domain.model.AlertType
import com.unipark.android.domain.model.LocationInfo
import com.unipark.android.domain.model.OccupancyData
import com.unipark.android.domain.model.PermitInfo
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class DashboardViewModel @Inject constructor() : ViewModel() {

    private val _permit = MutableStateFlow(fakePermit)
    val permit: StateFlow<PermitInfo> = _permit.asStateFlow()

    private val _location = MutableStateFlow(fakeLocation)
    val location: StateFlow<LocationInfo> = _location.asStateFlow()

    private val _occupancy = MutableStateFlow(fakeOccupancy)
    val occupancy: StateFlow<List<OccupancyData>> = _occupancy.asStateFlow()

    private val _alerts = MutableStateFlow(fakeAlerts)
    val alerts: StateFlow<List<AlertItem>> = _alerts.asStateFlow()

    companion object {
        val fakePermit = PermitInfo(
            permitName = "Semester Parking",
            status = "Active",
            validUntil = "Dec 31, 2026",
            vehiclePlate = "ABC 1234",
        )

        val fakeLocation = LocationInfo(
            lotName = "Main Campus Garage",
            spotNumber = "A-47",
            parkedSince = "Today, 8:30 AM",
        )

        val fakeOccupancy = listOf(
            OccupancyData(lotName = "Main Campus Garage", percentage = 72),
            OccupancyData(lotName = "West Lot", percentage = 91),
            OccupancyData(lotName = "South Deck", percentage = 45),
        )

        val fakeAlerts = listOf(
            AlertItem(
                title = "Lot Maintenance",
                body = "West Lot levels 2-3 closed for resurfacing May 28-30. Use South Deck as alternative.",
                timestamp = "2h ago",
                type = AlertType.Maintenance,
            ),
            AlertItem(
                title = "Event Parking",
                body = "Stadium event today at 6 PM. East Lot and Arena Deck reserved for attendees.",
                timestamp = "5h ago",
                type = AlertType.Info,
            ),
            AlertItem(
                title = "Permit Expiry",
                body = "Your semester permit expires Dec 31. Renewal opens Nov 15 with early-bird pricing.",
                timestamp = "1d ago",
                type = AlertType.Warning,
            ),
        )
    }
}
```

- [ ] **Step 2: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/presentation/dashboard/DashboardViewModel.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: add DashboardViewModel with fake data"
```

---

### Task 3: ActivePermitCard

**Files:**
- Create: `android/app/src/main/java/com/unipark/android/presentation/dashboard/components/ActivePermitCard.kt`

- [ ] **Step 1: Create directory**

```bash
mkdir -p /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark/android/app/src/main/java/com/unipark/android/presentation/dashboard/components
```

- [ ] **Step 2: Write ActivePermitCard.kt**

```kotlin
package com.unipark.android.presentation.dashboard.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Verified
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.components.GlowActivePanel
import com.unipark.android.core.ui.components.StatusPill
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.PrimaryFixedDim
import com.unipark.android.core.ui.theme.SecondaryFixed
import com.unipark.android.domain.model.PermitInfo

@Composable
fun ActivePermitCard(
    permit: PermitInfo,
    modifier: Modifier = Modifier,
) {
    GlowActivePanel(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp),
        cornerRadius = 16.dp,
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            // Verified badge row
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Verified,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp),
                    tint = SecondaryFixed,
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Active Permit",
                    style = MaterialTheme.typography.labelMedium,
                    color = SecondaryFixed,
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Permit name
            Text(
                text = permit.permitName,
                style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.Bold),
                color = MaterialTheme.colorScheme.onBackground,
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Status pill
            StatusPill(label = permit.status)

            Spacer(modifier = Modifier.height(16.dp))

            // Detail row
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Valid Until",
                        style = MaterialTheme.typography.labelSmall,
                        color = OnSurfaceVariant,
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = permit.validUntil,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onBackground,
                    )
                }
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Vehicle",
                        style = MaterialTheme.typography.labelSmall,
                        color = OnSurfaceVariant,
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = permit.vehiclePlate,
                        style = MaterialTheme.typography.bodyMedium,
                        color = PrimaryFixedDim,
                    )
                }
            }
        }
    }
}
```

- [ ] **Step 3: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/presentation/dashboard/components/ActivePermitCard.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: add ActivePermitCard with glow panel and status pill"
```

---

### Task 4: CurrentLocationCard

**Files:**
- Create: `android/app/src/main/java/com/unipark/android/presentation/dashboard/components/CurrentLocationCard.kt`

- [ ] **Step 1: Write CurrentLocationCard.kt**

```kotlin
package com.unipark.android.presentation.dashboard.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.MyLocation
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.components.GlassPanel
import com.unipark.android.core.ui.components.ShineButton
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.PrimaryFixedDim
import com.unipark.android.core.ui.theme.SurfaceContainerHigh
import com.unipark.android.domain.model.LocationInfo

@Composable
fun CurrentLocationCard(
    location: LocationInfo,
    onFindMyCar: () -> Unit = {},
    modifier: Modifier = Modifier,
) {
    GlassPanel(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp),
        cornerRadius = 12.dp,
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            // Section header
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.LocationOn,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp),
                    tint = PrimaryFixedDim,
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Current Location",
                    style = MaterialTheme.typography.labelMedium,
                    color = OnSurfaceVariant,
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Lot name + spot
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.Baseline,
            ) {
                Text(
                    text = location.lotName,
                    style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.SemiBold),
                    color = MaterialTheme.colorScheme.onBackground,
                    modifier = Modifier.weight(1f),
                )
                Text(
                    text = "Spot ${location.spotNumber}",
                    style = MaterialTheme.typography.bodyMedium,
                    color = PrimaryFixedDim,
                )
            }

            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "Parked since ${location.parkedSince}",
                style = MaterialTheme.typography.labelSmall,
                color = OnSurfaceVariant,
            )

            Spacer(modifier = Modifier.height(16.dp))

            ShineButton(
                label = "Find My Car",
                onClick = onFindMyCar,
                icon = Icons.Default.MyLocation,
                modifier = Modifier.fillMaxWidth(),
                containerColor = SurfaceContainerHigh,
                contentColor = PrimaryFixedDim,
                borderColor = PrimaryFixedDim.copy(alpha = 0.3f),
            )
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/presentation/dashboard/components/CurrentLocationCard.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: add CurrentLocationCard with Find My Car button"
```

---

### Task 5: CampusTrendsCard

**Files:**
- Create: `android/app/src/main/java/com/unipark/android/presentation/dashboard/components/CampusTrendsCard.kt`

- [ ] **Step 1: Write CampusTrendsCard.kt**

```kotlin
package com.unipark.android.presentation.dashboard.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.TrendingUp
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.components.GlassPanel
import com.unipark.android.core.ui.components.OccupancyBar
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.PrimaryFixedDim
import com.unipark.android.domain.model.OccupancyData

@Composable
fun CampusTrendsCard(
    occupancy: List<OccupancyData>,
    modifier: Modifier = Modifier,
) {
    GlassPanel(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp),
        cornerRadius = 12.dp,
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            // Section header
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.TrendingUp,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp),
                    tint = PrimaryFixedDim,
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Campus Trends",
                    style = MaterialTheme.typography.labelMedium,
                    color = OnSurfaceVariant,
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            occupancy.forEachIndexed { index, lot ->
                OccupancyBar(
                    label = lot.lotName,
                    percentage = lot.percentage,
                )
                if (index < occupancy.size - 1) {
                    Spacer(modifier = Modifier.height(16.dp))
                }
            }
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/presentation/dashboard/components/CampusTrendsCard.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: add CampusTrendsCard with occupancy bars"
```

---

### Task 6: SystemAlertsCard

**Files:**
- Create: `android/app/src/main/java/com/unipark/android/presentation/dashboard/components/SystemAlertsCard.kt`

- [ ] **Step 1: Write SystemAlertsCard.kt**

```kotlin
package com.unipark.android.presentation.dashboard.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.Campaign
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.components.GlassPanel
import com.unipark.android.core.ui.theme.Error
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.SecondaryFixed
import com.unipark.android.core.ui.theme.SurfaceContainer
import com.unipark.android.core.ui.theme.SurfaceVariant
import com.unipark.android.domain.model.AlertItem
import com.unipark.android.domain.model.AlertType

@Composable
fun SystemAlertsCard(
    alerts: List<AlertItem>,
    modifier: Modifier = Modifier,
) {
    GlassPanel(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp),
        cornerRadius = 12.dp,
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            // Section header
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Campaign,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp),
                    tint = SecondaryFixed,
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "System Alerts",
                    style = MaterialTheme.typography.labelMedium,
                    color = OnSurfaceVariant,
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            alerts.forEachIndexed { index, alert ->
                AlertRow(alert = alert)
                if (index < alerts.size - 1) {
                    Spacer(modifier = Modifier.height(12.dp))
                }
            }
        }
    }
}

@Composable
private fun AlertRow(alert: AlertItem) {
    val (icon, iconTint) = when (alert.type) {
        AlertType.Info -> Icons.Default.Info to SecondaryFixed
        AlertType.Warning -> Icons.Default.Warning to Error
        AlertType.Maintenance -> Icons.Default.Build to OnSurfaceVariant
    }

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.Top,
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .background(SurfaceContainer),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(18.dp),
                tint = iconTint,
            )
        }

        Spacer(modifier = Modifier.width(12.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = alert.title,
                style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.SemiBold),
                color = MaterialTheme.colorScheme.onBackground,
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = alert.body,
                style = MaterialTheme.typography.bodyMedium,
                color = OnSurfaceVariant,
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = alert.timestamp,
                style = MaterialTheme.typography.labelSmall,
                color = OnSurfaceVariant.copy(alpha = 0.6f),
            )
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/presentation/dashboard/components/SystemAlertsCard.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: add SystemAlertsCard with alert list"
```

---

### Task 7: Rewrite DashboardScreen with ViewModel + staggered entrance

**Files:**
- Modify: `android/app/src/main/java/com/unipark/android/presentation/dashboard/DashboardScreen.kt`

- [ ] **Step 1: Write DashboardScreen.kt (replacing placeholder)**

```kotlin
package com.unipark.android.presentation.dashboard

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.unipark.android.core.ui.components.entranceAnimation
import com.unipark.android.presentation.dashboard.components.ActivePermitCard
import com.unipark.android.presentation.dashboard.components.CampusTrendsCard
import com.unipark.android.presentation.dashboard.components.CurrentLocationCard
import com.unipark.android.presentation.dashboard.components.SystemAlertsCard

@Composable
fun DashboardScreen(
    viewModel: DashboardViewModel = hiltViewModel(),
) {
    val permit by viewModel.permit.collectAsState()
    val location by viewModel.location.collectAsState()
    val occupancy by viewModel.occupancy.collectAsState()
    val alerts by viewModel.alerts.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(vertical = 16.dp),
    ) {
        // Hero card — stager delay 0
        ActivePermitCard(
            permit = permit,
            modifier = Modifier.entranceAnimation(delayIndex = 0),
        )

        Spacer(modifier = Modifier.height(12.dp))

        // Current location — stagger delay 1
        CurrentLocationCard(
            location = location,
            modifier = Modifier.entranceAnimation(delayIndex = 1),
        )

        Spacer(modifier = Modifier.height(12.dp))

        // Campus trends — stagger delay 2
        CampusTrendsCard(
            occupancy = occupancy,
            modifier = Modifier.entranceAnimation(delayIndex = 2),
        )

        Spacer(modifier = Modifier.height(12.dp))

        // System alerts — stagger delay 3
        SystemAlertsCard(
            alerts = alerts,
            modifier = Modifier.entranceAnimation(delayIndex = 3),
        )

        Spacer(modifier = Modifier.height(24.dp))
    }
}
```

- [ ] **Step 2: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/presentation/dashboard/DashboardScreen.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: wire DashboardScreen with ViewModel and staggered entrance animations"
```

---

### Task 8: Wire DashboardScreen into NavGraph

**Files:**
- Modify: `android/app/src/main/java/com/unipark/android/core/navigation/NavGraph.kt`

- [ ] **Step 1: Update NavGraph to use real DashboardScreen**

Replace the `composable(Routes.DASHBOARD)` block. Change:

```kotlin
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import com.unipark.android.presentation.dashboard.DashboardScreen
```

And in the NavHost composables block, replace:
```kotlin
composable(Routes.DASHBOARD) {
    PlaceholderScreen("Dashboard")
}
```

with:
```kotlin
composable(Routes.DASHBOARD) {
    DashboardScreen()
}
```

Full updated imports section of NavGraph.kt:

```kotlin
package com.unipark.android.core.navigation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Dashboard
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.Payments
import androidx.compose.material.icons.filled.QrCodeScanner
import androidx.compose.material.icons.outlined.Dashboard
import androidx.compose.material.icons.outlined.Map
import androidx.compose.material.icons.outlined.Payments
import androidx.compose.material.icons.outlined.QrCodeScanner
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.unipark.android.presentation.dashboard.DashboardScreen
```

Full updated NavHost section:

```kotlin
NavHost(
    navController = navController,
    startDestination = Routes.DASHBOARD,
    modifier = Modifier.padding(innerPadding),
) {
    composable(Routes.DASHBOARD) {
        DashboardScreen()
    }
    composable(Routes.MAP) {
        PlaceholderScreen("Availability Map")
    }
    composable(Routes.PERMITS) {
        PlaceholderScreen("Permits")
    }
    composable(Routes.ACCESS) {
        PlaceholderScreen("Access Gate")
    }
}
```

- [ ] **Step 2: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/core/navigation/NavGraph.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: wire DashboardScreen into NavGraph replacing placeholder"
```

---

## Phase 2 Completion Checklist

After all tasks complete, verify:

- [ ] `DashboardModels.kt` defines `PermitInfo`, `LocationInfo`, `OccupancyData`, `AlertItem`, `AlertType`
- [ ] `DashboardViewModel.kt` exposes 4 StateFlow properties with fake data
- [ ] `ActivePermitCard.kt` uses `GlowActivePanel` + `StatusPill` + permit details
- [ ] `CurrentLocationCard.kt` uses `GlassPanel` + location icon + `ShineButton`
- [ ] `CampusTrendsCard.kt` uses `GlassPanel` + 3 `OccupancyBar` instances
- [ ] `SystemAlertsCard.kt` uses `GlassPanel` + alert rows with colored icon circles
- [ ] `DashboardScreen.kt` scrolls 4 cards with `entranceAnimation` modifier (delays 0-3)
- [ ] `NavGraph.kt` routes `/dashboard` to `DashboardScreen()` instead of placeholder
- [ ] Tab 1 "Status" shows the full dashboard
