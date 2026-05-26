package com.unipark.android.presentation.map.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.components.PulseRing
import com.unipark.android.core.ui.theme.GlassBackground
import com.unipark.android.core.ui.theme.GlassBorderLight
import com.unipark.android.core.ui.theme.PinFull
import com.unipark.android.core.ui.theme.PinOpen
import com.unipark.android.domain.model.LotInfo

@Composable
fun LotPin(
    lot: LotInfo,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val pinColor = if (lot.occupancy > 85) PinFull else PinOpen
    val statusLabel = "${lot.occupancy}%"

    Box(modifier = modifier) {
        // Pulse ring behind the dot
        Box(
            modifier = Modifier.align(Alignment.Center),
            contentAlignment = Alignment.Center,
        ) {
            PulseRing(color = pinColor, size = 48.dp, ringCount = 2)
        }

        // Central dot
        Box(
            modifier = Modifier
                .align(Alignment.Center)
                .size(10.dp)
                .clip(CircleShape)
                .background(pinColor),
        )

        // GlassBubble label above
        Column(
            modifier = Modifier
                .align(Alignment.TopCenter)
                .offset(y = (-40).dp)
                .clip(RoundedCornerShape(8.dp))
                .background(GlassBackground)
                .border(1.dp, GlassBorderLight, RoundedCornerShape(8.dp))
                .clickable(onClick = onClick)
                .padding(horizontal = 10.dp, vertical = 6.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                text = lot.name,
                style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.SemiBold),
                color = Color.White,
                textAlign = TextAlign.Center,
            )
            Text(
                text = statusLabel,
                style = MaterialTheme.typography.labelSmall,
                color = pinColor,
            )
        }
    }
}
