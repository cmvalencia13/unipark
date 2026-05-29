package com.unipark.android.presentation.driver

import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Business
import androidx.compose.material.icons.outlined.Badge
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.unipark.android.domain.entities.ParkingLot
import com.unipark.android.presentation.UniParkCardRadius
import com.unipark.android.presentation.UniParkFull
import com.unipark.android.presentation.UniParkSuccess
import com.unipark.android.presentation.UniParkWarning

@Composable
fun DriverDashboardScreen(
    onOpenPass: () -> Unit,
    viewModel: DriverDashboardViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        WelcomeHeaderCard()

        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            state.lots.forEach { lot ->
                ParkingLotSummaryCard(lot)
            }
        }

        Button(
            onClick = onOpenPass,
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            shape = RoundedCornerShape(UniParkCardRadius),
        ) {
            Icon(Icons.Outlined.Badge, contentDescription = null)
            Spacer(Modifier.width(8.dp))
            Text("Ver mi Pase Digital", fontWeight = FontWeight.Bold)
        }

        state.lots.forEach { lot ->
            LotCard(lot)
        }

        state.error?.let {
            Text("No se pudieron cargar lotes: $it", color = MaterialTheme.colorScheme.error)
        }
    }
}

@Composable
private fun WelcomeHeaderCard() {
    ElevatedCard(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(UniParkCardRadius),
        elevation = CardDefaults.elevatedCardElevation(defaultElevation = 2.dp),
    ) {
        Row(
            modifier = Modifier.padding(18.dp),
            horizontalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(MaterialTheme.colorScheme.primaryContainer),
            ) {
                Icon(
                    Icons.Default.Business,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onPrimaryContainer,
                    modifier = Modifier
                        .padding(10.dp)
                        .fillMaxSize(),
                )
            }
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text("Bienvenido a UniPark", style = MaterialTheme.typography.headlineSmall)
                Text(
                    "Campus Universidad - estacionamiento inteligente",
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

@Composable
private fun ParkingLotSummaryCard(lot: ParkingLot) {
    val color = occupancyColor(lot)
    ElevatedCard(
        modifier = Modifier.width(210.dp),
        shape = RoundedCornerShape(UniParkCardRadius),
        elevation = CardDefaults.elevatedCardElevation(defaultElevation = 2.dp),
        colors = CardDefaults.elevatedCardColors(containerColor = color.copy(alpha = 0.18f)),
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(lot.name, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                if (lot.isFull) FullBadge()
            }
            Text(
                "${(lot.occupancyPercentage * 100).toInt()}%",
                style = MaterialTheme.typography.headlineMedium,
                color = color,
                fontWeight = FontWeight.Bold,
            )
            Text("${lot.availableSpots} espacios libres")
        }
    }
}

@Composable
private fun LotCard(lot: ParkingLot) {
    val color = occupancyColor(lot)
    ElevatedCard(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(UniParkCardRadius),
        elevation = CardDefaults.elevatedCardElevation(defaultElevation = 2.dp),
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(lot.name, style = MaterialTheme.typography.titleMedium)
                Text("${lot.availableSpots} libres")
            }
            LinearProgressIndicator(
                progress = { lot.occupancyPercentage.toFloat().coerceIn(0f, 1f) },
                modifier = Modifier.fillMaxWidth(),
                color = color,
            )
            Text("${lot.capacityUsed}/${lot.capacityTotal} ocupados")
        }
    }
}

@Composable
private fun FullBadge() {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(999.dp))
            .background(UniParkFull)
            .padding(horizontal = 8.dp, vertical = 3.dp),
    ) {
        Text("LLENO", color = Color.White, style = MaterialTheme.typography.labelSmall)
    }
}

private fun occupancyColor(lot: ParkingLot): Color = when {
    lot.occupancyPercentage >= 0.9 -> UniParkFull
    lot.occupancyPercentage >= 0.7 -> UniParkWarning
    else -> UniParkSuccess
}
