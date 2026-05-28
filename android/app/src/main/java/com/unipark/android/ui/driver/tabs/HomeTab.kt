package com.unipark.android.ui.driver.tabs

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.QrCode
import androidx.compose.material.icons.filled.WarningAmber
import androidx.compose.material.icons.outlined.Place
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.unipark.android.domain.entities.ParkingLot
import com.unipark.android.ui.driver.DriverViewModel
import com.unipark.android.ui.driver.ScanResult
import com.unipark.android.ui.theme.GlassCard
import com.unipark.android.ui.theme.upBackground
import com.unipark.android.ui.theme.upPrimary
import com.unipark.android.ui.theme.upSecondary
import com.unipark.android.ui.theme.upSurfaceHighest
import com.unipark.android.ui.theme.upTextPrimary
import com.unipark.android.ui.theme.upTextSecondary
import kotlinx.coroutines.delay
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale

@Composable
fun HomeTab(
    viewModel: DriverViewModel,
    onOpenAccess: () -> Unit,
) {
    val lots by viewModel.lots.collectAsState()
    val lastScan by viewModel.lastEntryScan.collectAsState()
    var now by remember { mutableStateOf(LocalDateTime.now()) }

    LaunchedEffect(Unit) {
        while (true) {
            now = LocalDateTime.now()
            delay(60_000)
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(upBackground),
    ) {
        TimeHeader(now)
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            ActivePermitCard()
            lastScan?.let { LastEntryCard(it) }
            QuickActionCard(onOpenAccess)
            CampusTrendsCard(lots)
            SystemAlertCard()
        }
    }
}

@Composable
private fun TimeHeader(now: LocalDateTime) {
    val dateFormatter = remember {
        DateTimeFormatter.ofPattern("EEEE, d 'de' MMMM", Locale("es", "SV"))
    }
    val timeFormatter = remember { DateTimeFormatter.ofPattern("hh:mm a", Locale.US) }
    Column(
        modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(2.dp),
    ) {
        Text(
            text = now.format(dateFormatter).replaceFirstChar { it.uppercase() },
            color = upTextSecondary,
            fontSize = 14.sp,
        )
        Text(
            text = now.format(timeFormatter),
            color = upTextPrimary,
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
        )
    }
}

@Composable
private fun ActivePermitCard() {
    GlassCard(modifier = Modifier.fillMaxWidth(), glowColor = upPrimary.copy(alpha = 0.18f)) {
        Column(
            modifier = Modifier.padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    SectionLabel("PERMISO ACTIVO")
                    Text("Commuter Zone A", color = upTextPrimary, fontSize = 24.sp, fontWeight = FontWeight.Bold)
                    Text("Expira el 31 de mayo, 2026", color = upTextSecondary)
                }
                ValidCapsule()
            }
            Text("Gestionar ->", color = upPrimary, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
private fun ValidCapsule() {
    val transition = rememberInfiniteTransition(label = "valid-dot")
    val alpha by transition.animateFloat(
        initialValue = 0.35f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(850), RepeatMode.Reverse),
        label = "dot-alpha",
    )
    Row(
        modifier = Modifier
            .background(upSecondary.copy(alpha = 0.18f), RoundedCornerShape(999.dp))
            .padding(horizontal = 10.dp, vertical = 7.dp),
        horizontalArrangement = Arrangement.spacedBy(7.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .alpha(alpha)
                .background(upSecondary, RoundedCornerShape(999.dp)),
        )
        Text("Permiso Valido", color = upSecondary, fontSize = 12.sp, fontWeight = FontWeight.Bold)
    }
}

@Composable
private fun LastEntryCard(lastScan: ScanResult) {
    GlassCard(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.padding(18.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(Icons.Outlined.Place, contentDescription = null, tint = upSecondary, modifier = Modifier.size(26.dp))
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                SectionLabel("ULTIMA ENTRADA ESCANEADA")
                Text(lastScan.lotName, color = upTextPrimary, fontSize = 24.sp, fontWeight = FontWeight.Bold)
                Text("Escaneado a las 08:45 AM • ${lastScan.level}", color = upTextSecondary)
            }
        }
    }
}

@Composable
private fun QuickActionCard(onOpenAccess: () -> Unit) {
    Button(
        onClick = onOpenAccess,
        modifier = Modifier.fillMaxWidth(),
        colors = ButtonDefaults.buttonColors(containerColor = upSecondary, contentColor = upBackground),
        shape = RoundedCornerShape(16.dp),
    ) {
        Icon(Icons.Default.QrCode, contentDescription = null)
        Text("Ver mi Pase Digital ->", modifier = Modifier.padding(10.dp), fontWeight = FontWeight.Bold)
    }
}

@Composable
private fun CampusTrendsCard(lots: List<ParkingLot>) {
    GlassCard(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            SectionLabel("OCUPACION DEL CAMPUS")
            lots.forEach { lot ->
                val percentage = (lot.occupancyPercentage * 100).toInt()
                Column(verticalArrangement = Arrangement.spacedBy(7.dp)) {
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text(lot.name, color = upTextPrimary, fontWeight = FontWeight.SemiBold)
                        Text("$percentage% lleno", color = upPrimary)
                    }
                    LinearProgressIndicator(
                        progress = { lot.occupancyPercentage.toFloat().coerceIn(0f, 1f) },
                        modifier = Modifier.fillMaxWidth(),
                        color = upSecondary,
                        trackColor = upSurfaceHighest,
                    )
                }
            }
        }
    }
}

@Composable
private fun SystemAlertCard() {
    GlassCard(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.padding(18.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(Icons.Default.WarningAmber, contentDescription = null, tint = Color(0xFFFFC107))
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text("Mantenimiento en Lote C manana", color = upTextPrimary, fontWeight = FontWeight.Bold)
                Text("HACE 4 HORAS", color = upTextSecondary, fontSize = 11.sp)
            }
        }
    }
}

@Composable
private fun SectionLabel(text: String) {
    Text(
        text = text,
        color = upPrimary,
        fontSize = 11.sp,
        fontWeight = FontWeight.Bold,
        letterSpacing = 1.1.sp,
    )
}
