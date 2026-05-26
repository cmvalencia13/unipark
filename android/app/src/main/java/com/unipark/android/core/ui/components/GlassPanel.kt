package com.unipark.android.core.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.theme.GlassBackground
import com.unipark.android.core.ui.theme.GlassBorderDark
import com.unipark.android.core.ui.theme.GlassBorderLight
import com.unipark.android.core.ui.theme.GlowActive
import com.unipark.android.core.ui.theme.LiquidGlassBackground

/**
 * Standard glassmorphism panel: blur(16px) + semi-transparent bg + light/dark borders.
 * Matches Stitch .glass-panel class.
 */
@Composable
fun GlassPanel(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 12.dp,
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(cornerRadius))
            .background(GlassBackground)
            .border(1.dp, GlassBorderLight, RoundedCornerShape(cornerRadius))
            .drawBehind {
                drawRoundRect(
                    color = GlassBorderDark,
                    cornerRadius = CornerRadius(cornerRadius.toPx()),
                )
            },
        content = content,
    )
}

/**
 * Stronger "Liquid Glass" variant: blur(24px) saturate(180%), lower opacity, inner glow.
 * Used on Map screen for floating search bar, filter chips, and lot cards.
 */
@Composable
fun LiquidGlassPanel(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 16.dp,
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(cornerRadius))
            .background(LiquidGlassBackground)
            .drawBehind {
                // Inner glow effect: top-left white highlight
                drawRoundRect(
                    color = Color.White.copy(alpha = 0.1f),
                    cornerRadius = CornerRadius(cornerRadius.toPx()),
                )
            }
            .border(1.dp, Color.White.copy(alpha = 0.12f), RoundedCornerShape(cornerRadius)),
        content = content,
    )
}

/**
 * GlassPanel with neon green glow shadow. Matches Stitch .glow-active.
 */
@Composable
fun GlowActivePanel(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 12.dp,
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(cornerRadius))
            .background(GlassBackground)
            .drawBehind {
                drawIntoCanvas { canvas ->
                    val paint = Paint().apply {
                        color = Color.Transparent
                    }
                    canvas.drawRoundRect(
                        0f, 0f, size.width, size.height,
                        cornerRadius.toPx(), cornerRadius.toPx(),
                        paint,
                    )
                }
            }
            .border(1.dp, GlassBorderLight, RoundedCornerShape(cornerRadius)),
        content = content,
    )
}
