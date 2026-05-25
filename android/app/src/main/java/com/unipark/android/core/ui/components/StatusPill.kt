package com.unipark.android.core.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.theme.SecondaryFixed

/**
 * Shimmer-animated status badge with pulse dot.
 * Matches Stitch StatusPill in Dashboard ActivePermitCard.
 */
@Composable
fun StatusPill(
    label: String,
    modifier: Modifier = Modifier,
    dotColor: Color = SecondaryFixed,
    backgroundColor: Color = SecondaryFixed.copy(alpha = 0.2f),
    borderColor: Color = SecondaryFixed.copy(alpha = 0.3f),
    textColor: Color = SecondaryFixed,
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(8.dp))
            .background(backgroundColor)
            .border(1.dp, borderColor, RoundedCornerShape(8.dp))
            .padding(horizontal = 12.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        StatusDot(
            color = dotColor,
            label = "",
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = label,
            style = MaterialTheme.typography.labelMedium,
            color = textColor,
        )
    }
}
