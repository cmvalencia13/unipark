package com.unipark.android.core.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.icons.Icons
import androidx.compose.material3.icons.filled.Notifications
import androidx.compose.material3.icons.filled.Person
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.OutlineVariant
import com.unipark.android.core.ui.theme.PrimaryFixedDim
import com.unipark.android.core.ui.theme.SecondaryFixed
import com.unipark.android.core.ui.theme.Surface
import com.unipark.android.core.ui.theme.SurfaceContainer

/**
 * Shared TopAppBar: avatar + centered "UniPark" logo + notification bell with green dot.
 * Matches Stitch TopAppBar across all 4 screens.
 */
@Composable
fun UniParkTopAppBar(
    modifier: Modifier = Modifier,
    onAvatarClick: () -> Unit = {},
    onNotificationsClick: () -> Unit = {},
    hasNotification: Boolean = true,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(64.dp)
            .background(Surface.copy(alpha = 0.7f))
            .border(0.5.dp, Color.White.copy(alpha = 0.1f)),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // Leading: Avatar
        Box(
            modifier = Modifier
                .padding(start = 20.dp)
                .size(40.dp)
                .clip(CircleShape)
                .background(SurfaceContainer)
                .border(1.dp, OutlineVariant.copy(alpha = 0.5f), CircleShape)
                .clickable(onClick = onAvatarClick),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = Icons.Default.Person,
                contentDescription = "Profile",
                modifier = Modifier.size(24.dp),
                tint = OnSurfaceVariant,
            )
        }

        // Center: Logo
        Text(
            text = "UniPark",
            style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.Bold),
            color = PrimaryFixedDim,
        )

        // Trailing: Notification bell
        Box(
            modifier = Modifier
                .padding(end = 20.dp)
                .size(40.dp)
                .clip(CircleShape)
                .clickable(onClick = onNotificationsClick),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = Icons.Default.Notifications,
                contentDescription = "Notifications",
                modifier = Modifier.size(24.dp),
                tint = PrimaryFixedDim,
            )
            if (hasNotification) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(SecondaryFixed)
                        .align(Alignment.TopEnd),
                )
            }
        }
    }
}
