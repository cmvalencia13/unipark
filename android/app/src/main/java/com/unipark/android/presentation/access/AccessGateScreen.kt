package com.unipark.android.presentation.access

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.HelpOutline
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.unipark.android.core.ui.components.ShineButton
import com.unipark.android.core.ui.components.StatusDot
import com.unipark.android.core.ui.components.entranceAnimation
import com.unipark.android.core.ui.theme.Background
import com.unipark.android.core.ui.theme.Error
import com.unipark.android.core.ui.theme.PinOpen
import com.unipark.android.domain.model.ScannerState
import com.unipark.android.presentation.access.components.AuthorizedVehicleCard
import com.unipark.android.presentation.access.components.ScannerCore
import com.unipark.android.presentation.access.components.hudGrid
import kotlinx.coroutines.delay

@Composable
fun AccessGateScreen(
    viewModel: AccessGateViewModel = hiltViewModel(),
) {
    val scannerState by viewModel.scannerState.collectAsState()
    val vehicle by viewModel.authorizedVehicle.collectAsState()
    val systemReady by viewModel.systemReady.collectAsState()

    // Auto-complete scan simulation: SCANNING -> SUCCESS after 2.5s, then reset after 3s
    // SUCCESS -> auto-reset to IDLE after 3s
    // ERROR -> stays until user taps
    LaunchedEffect(scannerState) {
        when (scannerState) {
            ScannerState.SCANNING -> {
                delay(2500)
                viewModel.completeScan(true)
            }
            ScannerState.SUCCESS -> {
                delay(3000)
                viewModel.resetScanner()
            }
            else -> {}
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Background),
    ) {
        // HUD grid background layer
        Box(
            modifier = Modifier
                .fillMaxSize()
                .hudGrid(),
        )

        // Content column
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(vertical = 16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween,
        ) {
            // Top section: Authorized Vehicle Card
            AuthorizedVehicleCard(
                vehicle = vehicle,
                modifier = Modifier
                    .padding(horizontal = 20.dp)
                    .entranceAnimation(delayIndex = 0),
            )

            // Center section: Scanner
            ScannerCore(
                state = scannerState,
                onTap = { viewModel.startScan() },
                modifier = Modifier.entranceAnimation(delayIndex = 1),
            )

            // Bottom section: Status + Help
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp)
                    .entranceAnimation(delayIndex = 2),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                if (systemReady) {
                    StatusDot(
                        color = PinOpen,
                        label = "System Ready",
                        pulseColor = PinOpen,
                    )
                }

                ShineButton(
                    label = "Need Assistance",
                    onClick = { },
                    icon = Icons.Default.HelpOutline,
                    containerColor = Error.copy(alpha = 0.1f),
                    contentColor = Error,
                    borderColor = Error.copy(alpha = 0.3f),
                )
            }
        }
    }
}
