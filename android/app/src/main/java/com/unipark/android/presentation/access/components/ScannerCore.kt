package com.unipark.android.presentation.access.components

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Nfc
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.theme.Error
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.PrimaryFixedDim
import com.unipark.android.core.ui.theme.SecondaryFixed
import com.unipark.android.domain.model.ScannerState

/**
 * Modifier that draws a subtle HUD-style grid background with a radial glow
 * radiating from the center. Inspired by cyberpunk / cyber-academic theming.
 *
 * Usage: Box(modifier = Modifier.hudGrid()) { … }
 */
fun Modifier.hudGrid(): Modifier = this.drawBehind {
    val gridColor = Color.White.copy(alpha = 0.04f)
    val step = 40.dp.toPx()
    var x = step
    while (x < size.width) {
        drawLine(gridColor, Offset(x, 0f), Offset(x, size.height), strokeWidth = 1f)
        x += step
    }
    var y = step
    while (y < size.height) {
        drawLine(gridColor, Offset(0f, y), Offset(size.width, y), strokeWidth = 1f)
        y += step
    }
    // Draw radial glow from center
    drawCircle(
        brush = Brush.radialGradient(
            colors = listOf(
                PrimaryFixedDim.copy(alpha = 0.08f),
                PrimaryFixedDim.copy(alpha = 0.02f),
                Color.Transparent,
            ),
            center = Offset(size.width / 2, size.height / 2),
            radius = size.minDimension / 2,
        ),
        radius = size.minDimension / 2,
    )
}

/**
 * Three expanding concentric circles that animate outwards in a staggered fashion.
 * The animation speed changes based on whether the scanner is actively scanning.
 * Similar to [PulseRing] but larger and with 3 rings.
 */
@Composable
fun ConcentricRings(
    color: Color,
    isScanning: Boolean,
    modifier: Modifier = Modifier,
    size: Dp = 200.dp,
) {
    val infiniteTransition = rememberInfiniteTransition(label = "concentricRings")

    Box(
        modifier = modifier.size(size),
        contentAlignment = Alignment.Center,
    ) {
        repeat(3) { index ->
            val scale by infiniteTransition.animateFloat(
                initialValue = 0.3f,
                targetValue = 1.5f,
                animationSpec = infiniteRepeatable(
                    animation = tween(
                        durationMillis = if (isScanning) 1500 else 2500,
                        delayMillis = index * (if (isScanning) 300 else 500),
                    ),
                    repeatMode = RepeatMode.Restart,
                ),
                label = "ringScale$index",
            )
            val alpha by infiniteTransition.animateFloat(
                initialValue = 0.6f,
                targetValue = 0f,
                animationSpec = infiniteRepeatable(
                    animation = tween(
                        durationMillis = if (isScanning) 1500 else 2500,
                        delayMillis = index * (if (isScanning) 300 else 500),
                    ),
                    repeatMode = RepeatMode.Restart,
                ),
                label = "ringAlpha$index",
            )

            Box(
                modifier = Modifier
                    .size(size)
                    .scale(scale)
                    .alpha(alpha)
                    .drawBehind {
                        drawCircle(
                            color = color,
                            radius = size.toPx() / 2,
                            style = Stroke(width = 1.5.dp.toPx()),
                        )
                    },
            )
        }
    }
}

/**
 * A horizontal gradient laser line that sweeps vertically up and down
 * while the scanner is active. When inactive this composable renders nothing.
 */
@Composable
fun ScanLaser(
    isActive: Boolean,
    modifier: Modifier = Modifier,
    color: Color = PrimaryFixedDim,
) {
    if (!isActive) return

    val infiniteTransition = rememberInfiniteTransition(label = "scanLaser")
    val scanFraction by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "scanFraction",
    )

    Canvas(modifier = modifier) {
        val laserY = size.height * scanFraction
        val laserWidth = size.width * 0.7f
        val leftX = (size.width - laserWidth) / 2

        drawLine(
            brush = Brush.horizontalGradient(
                colors = listOf(
                    Color.Transparent,
                    color.copy(alpha = 0.8f),
                    color,
                    color.copy(alpha = 0.8f),
                    Color.Transparent,
                ),
                startX = leftX,
                endX = leftX + laserWidth,
            ),
            start = Offset(leftX, laserY),
            end = Offset(leftX + laserWidth, laserY),
            strokeWidth = 2.dp.toPx(),
        )
    }
}

/**
 * Main composable that assembles the full scanner UI: concentric rings, scanning
 * laser, and a center icon / label. The visuals adapt to the current [ScannerState]:
 *
 * - IDLE: NFC icon + "Tap to Enter", rings animate slowly, tappable.
 * - SCANNING: NFC icon + "Scanning...", rings animate faster, laser sweeps.
 * - SUCCESS: check icon + "Access Granted" in green, static.
 * - ERROR: close icon + "Try Again" in red, tappable to retry.
 */
@Composable
fun ScannerCore(
    state: ScannerState,
    onTap: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val isScanning = state == ScannerState.SCANNING
    val isSuccess = state == ScannerState.SUCCESS
    val isError = state == ScannerState.ERROR

    val ringColor = when {
        isSuccess -> SecondaryFixed
        isError -> Error
        else -> PrimaryFixedDim
    }

    Box(
        modifier = modifier
            .size(280.dp)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
            ) {
                if (state == ScannerState.IDLE || state == ScannerState.ERROR) {
                    onTap()
                }
            },
        contentAlignment = Alignment.Center,
    ) {
        // Concentric animated rings
        ConcentricRings(
            color = ringColor.copy(alpha = 0.5f),
            isScanning = isScanning,
            size = 240.dp,
        )

        // Scanning laser (only visible during scanning)
        ScanLaser(
            isActive = isScanning,
            modifier = Modifier.size(200.dp),
            color = PrimaryFixedDim,
        )

        // Center icon/content
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            when {
                isSuccess -> {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = "Success",
                        modifier = Modifier.size(48.dp),
                        tint = SecondaryFixed,
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "Access Granted",
                        style = MaterialTheme.typography.labelMedium,
                        color = SecondaryFixed,
                    )
                }
                isError -> {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Error",
                        modifier = Modifier.size(48.dp),
                        tint = Error,
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "Try Again",
                        style = MaterialTheme.typography.labelMedium,
                        color = Error,
                    )
                }
                else -> {
                    Icon(
                        imageVector = Icons.Default.Nfc,
                        contentDescription = "NFC",
                        modifier = Modifier.size(40.dp),
                        tint = PrimaryFixedDim,
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = if (isScanning) "Scanning..." else "Tap to Enter",
                        style = MaterialTheme.typography.labelMedium,
                        color = if (isScanning) PrimaryFixedDim else OnSurfaceVariant,
                    )
                }
            }
        }
    }
}
