package com.unipark.android.ui.theme

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

val upBackground = Color(0xFF111317)
val upSurface = Color(0xFF1E2024)
val upSurfaceHigh = Color(0xFF282A2E)
val upSurfaceHighest = Color(0xFF333539)
val upPrimary = Color(0xFF00F0FF)
val upSecondary = Color(0xFF36FFC4)
val upTextPrimary = Color(0xFFE2E2E8)
val upTextSecondary = Color(0xFFB9CACB)
val upError = Color(0xFFFFB4AB)

private val UniParkDriverColorScheme = darkColorScheme(
    primary = upPrimary,
    onPrimary = upBackground,
    secondary = upSecondary,
    onSecondary = upBackground,
    background = upBackground,
    onBackground = upTextPrimary,
    surface = upSurface,
    onSurface = upTextPrimary,
    surfaceVariant = upSurfaceHigh,
    onSurfaceVariant = upTextSecondary,
    error = upError,
)

@Composable
fun UniParkDriverTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = UniParkDriverColorScheme,
        typography = MaterialTheme.typography,
        content = content,
    )
}

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    glowColor: Color? = null,
    content: @Composable () -> Unit,
) {
    val shape = RoundedCornerShape(16.dp)
    val shadowModifier = if (glowColor != null) {
        Modifier.shadow(18.dp, shape, ambientColor = glowColor, spotColor = glowColor)
    } else {
        Modifier
    }

    Box(
        modifier = modifier
            .then(shadowModifier)
            .background(upSurface.copy(alpha = 0.7f), shape)
            .border(BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)), shape),
    ) {
        Surface(
            color = Color.Transparent,
            shape = shape,
            content = content,
        )
    }
}
