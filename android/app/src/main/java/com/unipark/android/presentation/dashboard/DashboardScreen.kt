package com.unipark.android.presentation.dashboard

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
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
        // Hero card — stagger delay 0
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
