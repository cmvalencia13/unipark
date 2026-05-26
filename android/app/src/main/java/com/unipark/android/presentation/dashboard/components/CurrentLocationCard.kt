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
                verticalAlignment = Alignment.Bottom,
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
