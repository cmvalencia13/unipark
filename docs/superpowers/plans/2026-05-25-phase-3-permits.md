# Phase 3 — Permits Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Permits tab with ActivePermitCard (reused from Phase 2), VehicleCard list (standard + guest variant with dashed border), and PricingCard grid (3 tiers with ShineButton CTAs), driven by a fake-data ViewModel with staggered entrance animations.

**Architecture:** MVVM with fake in-memory data. PermitsViewModel exposes StateFlow properties consumed by PermitsScreen. VehicleCard and PricingCard are new composable components. ActivePermitCard is reused from Phase 2. No domain/data layers yet — those come in Phase 6.

**Tech Stack:** Kotlin 2.0, Jetpack Compose (BOM 2024.12), Material3, Hilt, Hilt Navigation Compose

---

## File Structure Map (new and modified)

```
unipark/android/app/src/main/java/com/unipark/android/
├── domain/
│   └── model/
│       └── PermitModels.kt              (NEW — VehicleInfo, PricingOption)
├── presentation/
│   └── permits/
│       ├── PermitsScreen.kt             (MODIFY — replace placeholder)
│       ├── PermitsViewModel.kt          (NEW — fake data VM)
│       └── components/
│           ├── VehicleCard.kt           (NEW)
│           └── PricingCard.kt           (NEW)
└── core/
    └── navigation/
        └── NavGraph.kt                  (MODIFY — wire PermitsScreen)
```

---

### Task 1: Permit domain models

**Files:**
- Create: `android/app/src/main/java/com/unipark/android/domain/model/PermitModels.kt`

- [ ] **Step 1: Create directory if needed**

```bash
mkdir -p /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark/android/app/src/main/java/com/unipark/android/domain/model
```

- [ ] **Step 2: Write PermitModels.kt**

```kotlin
package com.unipark.android.domain.model

data class VehicleInfo(
    val plate: String,
    val makeModel: String,
    val isGuest: Boolean = false,
    val validUntil: String? = null,
)

data class PricingOption(
    val name: String,
    val price: String,
    val description: String,
    val highlight: Boolean = false,
)
```

- [ ] **Step 3: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/domain/model/PermitModels.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: add permit domain models (VehicleInfo, PricingOption)"
```

---

### Task 2: PermitsViewModel with fake data

**Files:**
- Create: `android/app/src/main/java/com/unipark/android/presentation/permits/PermitsViewModel.kt`

- [ ] **Step 1: Create permits directory**

```bash
mkdir -p /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark/android/app/src/main/java/com/unipark/android/presentation/permits
```

- [ ] **Step 2: Write PermitsViewModel.kt**

```kotlin
package com.unipark.android.presentation.permits

import androidx.lifecycle.ViewModel
import com.unipark.android.domain.model.PermitInfo
import com.unipark.android.domain.model.PricingOption
import com.unipark.android.domain.model.VehicleInfo
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class PermitsViewModel @Inject constructor() : ViewModel() {

    private val _permits = MutableStateFlow(fakePermits)
    val permits: StateFlow<List<PermitInfo>> = _permits.asStateFlow()

    private val _vehicles = MutableStateFlow(fakeVehicles)
    val vehicles: StateFlow<List<VehicleInfo>> = _vehicles.asStateFlow()

    private val _pricingOptions = MutableStateFlow(fakePricing)
    val pricingOptions: StateFlow<List<PricingOption>> = _pricingOptions.asStateFlow()

    companion object {
        val fakePermits = listOf(
            PermitInfo(
                permitName = "Semester Parking",
                status = "Active",
                validUntil = "Dec 31, 2026",
                vehiclePlate = "ABC 1234",
            ),
        )

        val fakeVehicles = listOf(
            VehicleInfo(
                plate = "ABC 1234",
                makeModel = "Toyota Camry",
                isGuest = false,
            ),
            VehicleInfo(
                plate = "XYZ 9876",
                makeModel = "Honda Civic",
                isGuest = true,
                validUntil = "Today, 6:00 PM",
            ),
        )

        val fakePricing = listOf(
            PricingOption(
                name = "Semester Pass",
                price = "$150",
                description = "Full semester access to all campus lots. Best value for daily commuters.",
                highlight = false,
            ),
            PricingOption(
                name = "Monthly Pass",
                price = "$45/mo",
                description = "Flexible monthly billing. Pause or cancel anytime. Ideal for part-time students.",
                highlight = true,
            ),
            PricingOption(
                name = "Daily 5-Pack",
                price = "$25",
                description = "Five daily passes at a discount. Perfect for occasional visitors and guests.",
                highlight = false,
            ),
        )
    }
}
```

- [ ] **Step 3: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/presentation/permits/PermitsViewModel.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: add PermitsViewModel with fake data"
```

---

### Task 3: VehicleCard component

**Files:**
- Create: `android/app/src/main/java/com/unipark/android/presentation/permits/components/VehicleCard.kt`

- [ ] **Step 1: Create components directory**

```bash
mkdir -p /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark/android/app/src/main/java/com/unipark/android/presentation/permits/components
```

- [ ] **Step 2: Write VehicleCard.kt**

```kotlin
package com.unipark.android.presentation.permits.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DirectionsCar
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.PrimaryFixedDim
import com.unipark.android.core.ui.theme.SecondaryFixed
import com.unipark.android.core.ui.theme.SurfaceContainer
import com.unipark.android.core.ui.theme.SurfaceContainerHigh
import com.unipark.android.domain.model.VehicleInfo

@Composable
fun VehicleCard(
    vehicle: VehicleInfo,
    onDelete: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val shape = RoundedCornerShape(12.dp)

    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(shape)
            .then(
                if (vehicle.isGuest) {
                    Modifier.drawBehind {
                        drawRoundRect(
                            color = PrimaryFixedDim.copy(alpha = 0.3f),
                            cornerRadius = CornerRadius(12.dp.toPx()),
                            style = Stroke(
                                width = 2.dp.toPx(),
                                pathEffect = PathEffect.dashPathEffect(
                                    floatArrayOf(8.dp.toPx(), 6.dp.toPx()),
                                ),
                            ),
                        )
                    }
                } else {
                    Modifier
                        .background(SurfaceContainerHigh)
                        .border(1.dp, Color.White.copy(alpha = 0.08f), shape)
                }
            )
            .padding(16.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Car icon
            Icon(
                imageVector = Icons.Default.DirectionsCar,
                contentDescription = null,
                modifier = Modifier.size(24.dp),
                tint = if (vehicle.isGuest) PrimaryFixedDim else OnSurfaceVariant,
            )

            Spacer(modifier = Modifier.width(12.dp))

            // Plate + make/model
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = vehicle.plate,
                    style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.Bold),
                    color = MaterialTheme.colorScheme.onBackground,
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = vehicle.makeModel,
                    style = MaterialTheme.typography.bodyMedium,
                    color = OnSurfaceVariant,
                )
            }

            // Guest badge or delete
            if (vehicle.isGuest) {
                GuestBadge(validUntil = vehicle.validUntil)
            } else {
                IconButton(onClick = onDelete) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Remove vehicle",
                        modifier = Modifier.size(20.dp),
                        tint = OnSurfaceVariant,
                    )
                }
            }
        }
    }
}

@Composable
private fun GuestBadge(validUntil: String?) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(6.dp))
            .background(SecondaryFixed.copy(alpha = 0.15f))
            .padding(horizontal = 10.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            imageVector = Icons.Default.Schedule,
            contentDescription = null,
            modifier = Modifier.size(14.dp),
            tint = SecondaryFixed,
        )
        Spacer(modifier = Modifier.width(4.dp))
        if (validUntil != null) {
            Text(
                text = validUntil,
                style = MaterialTheme.typography.labelSmall,
                color = SecondaryFixed,
            )
        }
    }
}
```

- [ ] **Step 3: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/presentation/permits/components/VehicleCard.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: add VehicleCard with guest variant and dashed border"
```

---

### Task 4: PricingCard component

**Files:**
- Create: `android/app/src/main/java/com/unipark/android/presentation/permits/components/PricingCard.kt`

- [ ] **Step 1: Write PricingCard.kt**

```kotlin
package com.unipark.android.presentation.permits.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.unipark.android.core.ui.components.ShineButton
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.PrimaryFixedDim
import com.unipark.android.core.ui.theme.SecondaryFixed
import com.unipark.android.core.ui.theme.SurfaceContainerHigh
import com.unipark.android.domain.model.PricingOption

@Composable
fun PricingCard(
    option: PricingOption,
    onPurchase: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val borderColor = if (option.highlight) SecondaryFixed.copy(alpha = 0.4f) else Color.White.copy(alpha = 0.06f)

    Column(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(SurfaceContainerHigh)
            .border(1.dp, borderColor, RoundedCornerShape(12.dp))
            .padding(16.dp),
    ) {
        if (option.highlight) {
            Text(
                text = "Recommended",
                style = MaterialTheme.typography.labelSmall,
                color = SecondaryFixed,
                modifier = Modifier
                    .clip(RoundedCornerShape(4.dp))
                    .background(SecondaryFixed.copy(alpha = 0.1f))
                    .padding(horizontal = 8.dp, vertical = 4.dp),
            )
            Spacer(modifier = Modifier.height(8.dp))
        }

        Text(
            text = option.name,
            style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.SemiBold),
            color = MaterialTheme.colorScheme.onBackground,
        )

        Spacer(modifier = Modifier.height(4.dp))

        Text(
            text = option.price,
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = PrimaryFixedDim,
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = option.description,
            style = MaterialTheme.typography.bodyMedium,
            color = OnSurfaceVariant,
        )

        Spacer(modifier = Modifier.height(16.dp))

        ShineButton(
            label = "Purchase",
            onClick = onPurchase,
            icon = Icons.Default.ShoppingCart,
            modifier = Modifier.fillMaxWidth(),
            containerColor = if (option.highlight) SecondaryFixed.copy(alpha = 0.15f) else Color.White.copy(alpha = 0.08f),
            contentColor = if (option.highlight) SecondaryFixed else PrimaryFixedDim,
            borderColor = if (option.highlight) SecondaryFixed.copy(alpha = 0.3f) else Color.White.copy(alpha = 0.1f),
        )
    }
}
```

- [ ] **Step 2: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/presentation/permits/components/PricingCard.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: add PricingCard with highlight variant and purchase button"
```

---

### Task 5: Write PermitsScreen with ViewModel + staggered entrance

**Files:**
- Modify: `android/app/src/main/java/com/unipark/android/presentation/permits/PermitsScreen.kt`

- [ ] **Step 1: Write PermitsScreen.kt (replacing placeholder)**

```kotlin
package com.unipark.android.presentation.permits

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.DirectionsCar
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.unipark.android.core.ui.components.ShineButton
import com.unipark.android.core.ui.components.entranceAnimation
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.PrimaryFixedDim
import com.unipark.android.core.ui.theme.SurfaceContainerHigh
import com.unipark.android.presentation.dashboard.components.ActivePermitCard
import com.unipark.android.presentation.permits.components.PricingCard
import com.unipark.android.presentation.permits.components.VehicleCard

@Composable
fun PermitsScreen(
    viewModel: PermitsViewModel = hiltViewModel(),
) {
    val permits by viewModel.permits.collectAsState()
    val vehicles by viewModel.vehicles.collectAsState()
    val pricingOptions by viewModel.pricingOptions.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(vertical = 16.dp),
    ) {
        // ---- Active Permits Section ----
        SectionHeader(
            title = "Active Permits",
            modifier = Modifier.entranceAnimation(delayIndex = 0),
        )

        Spacer(modifier = Modifier.height(8.dp))

        permits.forEachIndexed { index, permit ->
            Column(modifier = Modifier.entranceAnimation(delayIndex = index)) {
                ActivePermitCard(
                    permit = permit,
                    modifier = Modifier.padding(horizontal = 20.dp),
                )

                // Manage link below the card
                TextButton(
                    onClick = { /* Manage permit — Phase 6 */ },
                    modifier = Modifier.padding(start = 20.dp, top = 4.dp),
                ) {
                    Text(
                        text = "Manage Permit",
                        style = MaterialTheme.typography.labelMedium,
                        color = PrimaryFixedDim,
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Icon(
                        imageVector = Icons.Default.ChevronRight,
                        contentDescription = null,
                        modifier = Modifier.size(16.dp),
                        tint = PrimaryFixedDim,
                    )
                }

                if (index < permits.size - 1) {
                    Spacer(modifier = Modifier.height(8.dp))
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // ---- Registered Vehicles Section ----
        SectionHeader(
            title = "Registered Vehicles",
            modifier = Modifier.entranceAnimation(delayIndex = 2),
        )

        Spacer(modifier = Modifier.height(8.dp))

        Column(modifier = Modifier.entranceAnimation(delayIndex = 3)) {
            vehicles.forEachIndexed { index, vehicle ->
                VehicleCard(
                    vehicle = vehicle,
                    onDelete = { /* Delete vehicle — Phase 6 */ },
                    modifier = Modifier.padding(horizontal = 20.dp),
                )
                if (index < vehicles.size - 1) {
                    Spacer(modifier = Modifier.height(8.dp))
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Add Guest Vehicle button
        ShineButton(
            label = "Add Guest Vehicle",
            onClick = { /* Add guest — Phase 6 */ },
            icon = Icons.Default.Add,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .entranceAnimation(delayIndex = 4),
            containerColor = SurfaceContainerHigh,
            contentColor = PrimaryFixedDim,
            borderColor = PrimaryFixedDim.copy(alpha = 0.2f),
        )

        Spacer(modifier = Modifier.height(24.dp))

        // ---- Purchase New Permit Section ----
        SectionHeader(
            title = "Purchase New Permit",
            modifier = Modifier.entranceAnimation(delayIndex = 5),
        )

        Spacer(modifier = Modifier.height(8.dp))

        // Pricing card grid (horizontal scroll on smaller screens)
        LazyRow(
            modifier = Modifier.entranceAnimation(delayIndex = 6),
            contentPadding = PaddingValues(horizontal = 20.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            items(pricingOptions.size) { index ->
                PricingCard(
                    option = pricingOptions[index],
                    onPurchase = { /* Purchase — Phase 6 */ },
                    modifier = Modifier.width(260.dp),
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))
    }
}

@Composable
private fun SectionHeader(
    title: String,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier.padding(horizontal = 20.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            imageVector = when (title) {
                "Active Permits" -> Icons.Default.DirectionsCar
                "Registered Vehicles" -> Icons.Default.DirectionsCar
                "Purchase New Permit" -> Icons.Default.ShoppingCart
                else -> Icons.Default.DirectionsCar
            },
            contentDescription = null,
            modifier = Modifier.size(20.dp),
            tint = PrimaryFixedDim,
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
            color = MaterialTheme.colorScheme.onBackground,
        )
    }
}
```

- [ ] **Step 2: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/presentation/permits/PermitsScreen.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: wire PermitsScreen with ViewModel, VehicleCards, PricingCards, and staggered animations"
```

---

### Task 6: Wire PermitsScreen into NavGraph

**Files:**
- Modify: `android/app/src/main/java/com/unipark/android/core/navigation/NavGraph.kt`

- [ ] **Step 1: Add import and replace PERMITS composable**

Add import at the top:
```kotlin
import com.unipark.android.presentation.permits.PermitsScreen
```

Replace the PERMITS placeholder composable in NavHost:
```kotlin
composable(Routes.PERMITS) {
    PermitsScreen()
}
```

Full NavHost after change:
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
        PermitsScreen()
    }
    composable(Routes.ACCESS) {
        PlaceholderScreen("Access Gate")
    }
}
```

- [ ] **Step 2: Commit**

```bash
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark add android/app/src/main/java/com/unipark/android/core/navigation/NavGraph.kt
git -C /c/Users/FelipeAndresCanasFla/Desktop/Proyectos_Progra/unipark commit -m "feat: wire PermitsScreen into NavGraph replacing placeholder"
```

---

## Phase 3 Completion Checklist

After all tasks complete, verify:

- [ ] `PermitModels.kt` defines `VehicleInfo` and `PricingOption` data classes
- [ ] `PermitsViewModel.kt` exposes 3 StateFlow properties with fake data
- [ ] `VehicleCard.kt` renders standard variant (solid border, delete button) and guest variant (dashed border, temp badge)
- [ ] `PricingCard.kt` renders with price, description, highlight badge, and ShineButton CTA
- [ ] `PermitsScreen.kt` scrolls 3 sections (Active Permits, Registered Vehicles, Purchase New Permit) with entrance animations
- [ ] `NavGraph.kt` routes `/permits` to `PermitsScreen()` instead of placeholder
- [ ] Tab 3 "Permits" shows the full permits UI
