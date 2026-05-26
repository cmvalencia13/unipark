package com.unipark.android.presentation.map.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import com.unipark.android.core.ui.theme.PinOpen
import com.unipark.android.core.ui.theme.SurfaceContainerLowest
import com.unipark.android.core.ui.theme.SurfaceVariant
import com.unipark.android.domain.model.LotInfo

@Composable
fun MapCanvas(
    lots: List<LotInfo>,
    modifier: Modifier = Modifier,
) {
    Canvas(modifier = modifier.fillMaxSize()) {
        val w = size.width
        val h = size.height

        // Background
        drawRect(color = SurfaceContainerLowest)

        // Road grid — horizontal and vertical dashed lines
        val roadColor = SurfaceVariant
        val dashPath = PathEffect.dashPathEffect(floatArrayOf(16f, 12f))

        // Horizontal roads
        for (i in 1..3) {
            val y = h * i / 4f
            drawLine(
                color = roadColor,
                start = Offset(0f, y),
                end = Offset(w, y),
                strokeWidth = 2f,
                pathEffect = dashPath,
            )
        }
        // Vertical roads
        for (i in 1..3) {
            val x = w * i / 4f
            drawLine(
                color = roadColor,
                start = Offset(x, 0f),
                end = Offset(x, h),
                strokeWidth = 2f,
                pathEffect = dashPath,
            )
        }

        // Lot zones — colored rectangles
        for (lot in lots) {
            val lotW = w * 0.3f
            val lotH = h * 0.15f
            val left = lot.xFraction * w - lotW / 2f
            val top = lot.yFraction * h - lotH / 2f

            val zoneColor = when {
                lot.occupancy > 85 -> Color(0x33FFB4AB)
                else -> Color(0x3336FFC4)
            }

            drawRoundRect(
                color = zoneColor,
                topLeft = Offset(left, top),
                size = Size(lotW, lotH),
                cornerRadius = CornerRadius(8f),
            )
            drawRoundRect(
                color = if (lot.occupancy > 85) Color.Red.copy(alpha = 0.3f) else PinOpen.copy(alpha = 0.3f),
                topLeft = Offset(left, top),
                size = Size(lotW, lotH),
                cornerRadius = CornerRadius(8f),
                style = Stroke(width = 1.5f),
            )
        }
    }
}
