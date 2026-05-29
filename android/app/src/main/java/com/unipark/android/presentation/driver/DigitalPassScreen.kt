package com.unipark.android.presentation.driver

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Wifi
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.unipark.android.presentation.UniParkCardRadius
import com.unipark.android.presentation.UniParkFull
import java.util.UUID

@Composable
fun DigitalPassScreen(
    vehicleId: UUID,
    viewModel: DigitalPassViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()

    LaunchedEffect(vehicleId) {
        if (state.pass == null) viewModel.generate(vehicleId)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterVertically),
    ) {
        Text("Pase digital", style = MaterialTheme.typography.headlineSmall)
        state.pass?.let { pass ->
            val qr = remember(pass.qrPayload) {
                generateQRBitmap(pass.qrPayload, 220).asImageBitmap()
            }
            Card(
                shape = RoundedCornerShape(UniParkCardRadius),
                colors = CardDefaults.cardColors(containerColor = Color.Black),
                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
            ) {
                Box(modifier = Modifier.padding(18.dp)) {
                    Image(
                        bitmap = qr,
                        contentDescription = "QR del pase",
                        modifier = Modifier
                            .size(220.dp)
                            .background(Color.White),
                    )
                }
            }
            Text(
                "Expira en ${state.secondsRemaining}s",
                color = if (state.secondsRemaining < 15) UniParkFull else MaterialTheme.colorScheme.onSurface,
                fontWeight = if (state.secondsRemaining < 15) FontWeight.Bold else FontWeight.Normal,
            )
            OutlinedButton(onClick = { }, shape = RoundedCornerShape(UniParkCardRadius)) {
                Icon(
                    Icons.Outlined.Wifi,
                    contentDescription = null,
                    modifier = Modifier.rotate(90f),
                )
                Text("Activar NFC")
            }
        }
        state.error?.let { Text(it, color = MaterialTheme.colorScheme.error) }
        Button(onClick = { viewModel.generate(vehicleId) }, shape = RoundedCornerShape(UniParkCardRadius)) {
            Text("Renovar pase")
        }
    }
}
