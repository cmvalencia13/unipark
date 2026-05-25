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

                TextButton(
                    onClick = { },
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
                    onDelete = { },
                    modifier = Modifier.padding(horizontal = 20.dp),
                )
                if (index < vehicles.size - 1) {
                    Spacer(modifier = Modifier.height(8.dp))
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        ShineButton(
            label = "Add Guest Vehicle",
            onClick = { },
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

        LazyRow(
            modifier = Modifier.entranceAnimation(delayIndex = 6),
            contentPadding = PaddingValues(horizontal = 20.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            items(pricingOptions.size) { index ->
                PricingCard(
                    option = pricingOptions[index],
                    onPurchase = { },
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
