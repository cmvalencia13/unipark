package com.unipark.android.core.ui.components

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Modifier: staggered slide-up fade entrance.
 * Apply with an index-based delay for staggered card animations.
 *
 * Usage: Modifier.entranceAnimation(delayIndex = 0)
 *         Modifier.entranceAnimation(delayIndex = 1)
 */
fun Modifier.entranceAnimation(delayIndex: Int = 0): Modifier = composed {
    var visible by remember { mutableFloatStateOf(0f) }

    LaunchedEffect(Unit) {
        visible = 1f
    }

    val delay = delayIndex * 100
    val animatedAlpha by animateFloatAsState(
        targetValue = visible,
        animationSpec = tween(
            durationMillis = 500,
            delayMillis = delay,
        ),
        label = "entranceAlpha",
    )
    val animatedOffset by animateFloatAsState(
        targetValue = if (visible > 0f) 0f else 20f,
        animationSpec = tween(
            durationMillis = 500,
            delayMillis = delay,
        ),
        label = "entranceOffset",
    )

    this
        .alpha(animatedAlpha)
        .graphicsLayer { translationY = animatedOffset }
}

/**
 * Expanding ring animation — useful for map pins and scanner.
 * Renders concentric pulsing rings.
 */
@Composable
fun PulseRing(
    color: Color,
    modifier: Modifier = Modifier,
    size: Dp = 48.dp,
    ringCount: Int = 2,
) {
    val infiniteTransition = rememberInfiniteTransition(label = "pulseRing")

    Box(modifier = modifier.size(size)) {
        repeat(ringCount) { index ->
            val scale by infiniteTransition.animateFloat(
                initialValue = 0.8f,
                targetValue = 2.5f,
                animationSpec = infiniteRepeatable(
                    animation = tween(2000, delayMillis = index * 500),
                    repeatMode = RepeatMode.Restart,
                    easing = LinearEasing,
                ),
                label = "ringScale$index",
            )
            val alpha by infiniteTransition.animateFloat(
                initialValue = 0.5f,
                targetValue = 0f,
                animationSpec = infiniteRepeatable(
                    animation = tween(2000, delayMillis = index * 500),
                    repeatMode = RepeatMode.Restart,
                    easing = LinearEasing,
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
                            style = Stroke(width = 2.dp.toPx()),
                        )
                    },
            )
        }
    }
}
