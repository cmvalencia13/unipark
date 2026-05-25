package com.unipark.android.presentation.map.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.Navigation
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.components.OccupancyBar
import com.unipark.android.core.ui.components.ShineButton
import com.unipark.android.core.ui.theme.Error
import com.unipark.android.core.ui.theme.GlassBackground
import com.unipark.android.core.ui.theme.PinOpen
import com.unipark.android.core.ui.theme.PrimaryFixedDim
import com.unipark.android.core.ui.theme.SecondaryFixed
import com.unipark.android.core.ui.theme.SurfaceContainer
import com.unipark.android.domain.model.LotInfo

@Composable
fun LotDetailSheet(
    lot: LotInfo?,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
) {
    AnimatedVisibility(
        visible = lot != null,
        enter = slideInVertically(initialOffsetY = { it }),
        exit = slideOutVertically(targetOffsetY = { it }),
        modifier = modifier,
    ) {
        lot?.let { selectedLot ->
            val accentColor = if (selectedLot.occupancy > 85) Error else PinOpen

            Box(modifier = Modifier.fillMaxWidth()) {
                // Scrim tap to dismiss
                Box(
                    modifier = Modifier
                        .matchParentSize()
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null,
                            onClick = onDismiss,
                        ),
                )

                // Sheet content
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp))
                        .background(GlassBackground)
                        .padding(20.dp),
                ) {
                    // Accent bar
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(4.dp)
                            .clip(RoundedCornerShape(2.dp))
                            .background(accentColor),
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    // Lot name
                    Text(
                        text = selectedLot.name,
                        style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.onBackground,
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Occupancy bar
                    OccupancyBar(
                        label = "Current Occupancy",
                        percentage = selectedLot.occupancy,
                    )

                    Spacer(modifier = Modifier.height(20.dp))

                    // Action buttons
                    Row(modifier = Modifier.fillMaxWidth()) {
                        ShineButton(
                            label = "Navigate",
                            onClick = { },
                            icon = Icons.Default.Navigation,
                            modifier = Modifier.weight(1f),
                            containerColor = SurfaceContainer,
                            contentColor = PrimaryFixedDim,
                            borderColor = PrimaryFixedDim.copy(alpha = 0.3f),
                        )
                        Spacer(modifier = Modifier.width(12.dp))
                        ShineButton(
                            label = "Bookmark",
                            onClick = { },
                            icon = Icons.Default.Bookmark,
                            modifier = Modifier.weight(1f),
                            containerColor = SurfaceContainer,
                            contentColor = SecondaryFixed,
                            borderColor = SecondaryFixed.copy(alpha = 0.3f),
                        )
                    }
                }
            }
        }
    }
}
