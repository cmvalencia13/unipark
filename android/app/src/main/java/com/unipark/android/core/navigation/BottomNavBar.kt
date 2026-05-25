package com.unipark.android.core.navigation

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.SecondaryFixed
import com.unipark.android.core.ui.theme.SurfaceContainer

/**
 * Tab item configuration.
 */
data class BottomNavTab(
    val route: String,
    val label: String,
    val icon: ImageVector,
    val filledIcon: ImageVector,
)

/**
 * Shared BottomNavBar: 4 tabs with glow indicator on active.
 * Matches Stitch BottomNavBar across all 4 screens.
 */
@Composable
fun UniParkBottomNavBar(
    tabs: List<BottomNavTab>,
    currentRoute: String,
    onTabClick: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(80.dp)
            .background(SurfaceContainer.copy(alpha = 0.8f))
            .border(0.5.dp, Color.White.copy(alpha = 0.1f)),
        horizontalArrangement = Arrangement.SpaceEvenly,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        tabs.forEach { tab ->
            val isActive = tab.route == currentRoute
            val color by animateColorAsState(
                targetValue = if (isActive) SecondaryFixed else OnSurfaceVariant.copy(alpha = 0.6f),
                animationSpec = tween(300),
                label = "tabColor",
            )

            val containerColor by animateColorAsState(
                targetValue = if (isActive) SecondaryFixed.copy(alpha = 0.2f) else Color.Transparent,
                animationSpec = tween(300),
                label = "tabBg",
            )

            Column(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(containerColor)
                    .clickable { onTabClick(tab.route) }
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Icon(
                    imageVector = if (isActive) tab.filledIcon else tab.icon,
                    contentDescription = tab.label,
                    modifier = Modifier.size(24.dp),
                    tint = color,
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = tab.label,
                    style = MaterialTheme.typography.labelSmall,
                    color = color,
                )
            }
        }
    }
}
