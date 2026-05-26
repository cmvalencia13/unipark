package com.unipark.android.core.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.theme.Error
import com.unipark.android.core.ui.theme.SecondaryFixed
import com.unipark.android.core.ui.theme.SurfaceVariant

/**
 * Label + percentage + colored progress bar with glow effect.
 * Used in Dashboard CampusTrends and Map LotDetailSheet.
 *
 * Color auto-selects based on percentage:
 * - > 85% → red (error)
 * - <= 85% → green (secondary-fixed)
 */
@Composable
fun OccupancyBar(
    label: String,
    percentage: Int,
    modifier: Modifier = Modifier,
    labelStyle: TextStyle = MaterialTheme.typography.labelSmall,
    barHeight: Dp = 6.dp,
) {
    val barColor = if (percentage > 85) Error else SecondaryFixed
    val statusLabel = "${percentage}% Full"

    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = label,
                style = labelStyle,
                color = MaterialTheme.colorScheme.onBackground,
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = statusLabel,
                style = labelStyle,
                color = barColor,
            )
        }
        Spacer(modifier = Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(barHeight)
                .clip(RoundedCornerShape(barHeight / 2))
                .background(SurfaceVariant),
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(fraction = percentage / 100f)
                    .height(barHeight)
                    .clip(RoundedCornerShape(barHeight / 2))
                    .background(barColor)
                    .drawBehind {
                        drawRoundRect(
                            color = barColor.copy(alpha = 0.6f),
                            cornerRadius = CornerRadius(barHeight.toPx() / 2),
                            style = Stroke(width = 4.dp.toPx()),
                        )
                    },
            )
        }
    }
}
