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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.components.GlassPanel
import com.unipark.android.core.ui.theme.Error
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.SecondaryFixed
import com.unipark.android.core.ui.theme.SurfaceContainer
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
