package com.unipark.android.ui.driver.tabs

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.unipark.android.presentation.driver.generateQRBitmap
import com.unipark.android.ui.driver.DriverViewModel
import com.unipark.android.ui.theme.GlassCard
import com.unipark.android.ui.theme.upBackground
import com.unipark.android.ui.theme.upPrimary
import com.unipark.android.ui.theme.upSecondary
import com.unipark.android.ui.theme.upSurfaceHigh
import com.unipark.android.ui.theme.upTextPrimary
import com.unipark.android.ui.theme.upTextSecondary
import kotlinx.coroutines.delay
import java.time.Duration
import java.time.Instant
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale

@Composable
fun AccessQRTab(viewModel: DriverViewModel) {
    val passPayload by viewModel.passPayload.collectAsState()
    val lastScan by viewModel.lastEntryScan.collectAsState()
    var now by remember { mutableStateOf(LocalDateTime.now()) }
    var instantNow by remember { mutableStateOf(Instant.now()) }
    var expanded by remember { mutableStateOf(false) }
    var showScanCard by remember { mutableStateOf(lastScan != null) }

    LaunchedEffect(Unit) {
        while (true) {
            now = LocalDateTime.now()
            instantNow = Instant.now()
            delay(1_000)
        }
    }

    LaunchedEffect(lastScan) {
        if (lastScan != null) {
            showScanCard = true
            delay(8_000)
            showScanCard = false
        }
    }

    val timeFormatter = remember { DateTimeFormatter.ofPattern("hh:mm a", Locale.US) }
    val dateFormatter = remember { DateTimeFormatter.ofPattern("EEEE, d 'de' MMMM", Locale("es", "SV")) }
    val content = passPayload?.payload ?: "unipark-pass-loading"
    val secondsRemaining = passPayload?.expiresAt?.let {
        Duration.between(instantNow, it).seconds.coerceAtLeast(0)
    } ?: 60
    val qr = remember(content) { generateQRBitmap(content, 260).asImageBitmap() }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(upBackground)
            .padding(20.dp),
    ) {
        Column(
            modifier = Modifier.align(Alignment.Center),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            Text(now.format(timeFormatter), color = upTextPrimary, fontSize = 32.sp, fontWeight = FontWeight.Bold)
            Text(
                now.format(dateFormatter).replaceFirstChar { it.uppercase() },
                color = upTextSecondary,
                fontSize = 14.sp,
            )
            Column(
                modifier = Modifier
                    .background(Color.White, RoundedCornerShape(20.dp))
                    .clickable { expanded = true }
                    .padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Image(bitmap = qr, contentDescription = "QR de acceso", modifier = Modifier.size(260.dp))
                Text("Toca para ampliar", color = Color.DarkGray, fontSize = 11.sp)
            }
            Text("Expira en ${secondsRemaining}s", color = upPrimary, fontSize = 18.sp, fontWeight = FontWeight.Bold)
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(upSurfaceHigh),
            )
            Button(onClick = viewModel::simulateScanResult) {
                Text("Simular ultimo scan")
            }
        }

        AnimatedVisibility(
            visible = showScanCard && lastScan != null,
            enter = slideInVertically(initialOffsetY = { it }),
            exit = slideOutVertically(targetOffsetY = { it }),
            modifier = Modifier.align(Alignment.BottomCenter),
        ) {
            GlassCard(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Box(
                        modifier = Modifier
                            .size(4.dp)
                            .height(64.dp)
                            .background(upSecondary, RoundedCornerShape(999.dp)),
                    )
                    Icon(Icons.Default.CheckCircle, contentDescription = null, tint = upSecondary)
                    Column {
                        Text(lastScan!!.direction, color = upTextPrimary, fontWeight = FontWeight.Bold)
                        Text("${lastScan!!.lotName} • ${lastScan!!.level} • ${now.format(timeFormatter)}", color = upTextSecondary)
                    }
                }
            }
        }
    }

    if (expanded) {
        AlertDialog(
            onDismissRequest = { expanded = false },
            confirmButton = {
                Button(onClick = { expanded = false }) {
                    Text("Cerrar")
                }
            },
            text = {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    val bigQr = remember(content) { generateQRBitmap(content, 340).asImageBitmap() }
                    Image(bitmap = bigQr, contentDescription = "QR ampliado", modifier = Modifier.size(340.dp))
                    Text("Muestra este codigo al guardia", color = Color.DarkGray, textAlign = TextAlign.Center)
                }
            },
        )
    }
}
