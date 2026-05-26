package com.unipark.android.core.ui.theme

import androidx.compose.ui.graphics.Color

// Stitch design system — extracted from "Swift Campus Parking" project
// Dark theme only ("cyber-academic" aesthetic)

// Primary — cyan/teal family
val Primary = Color(0xFFDBFCFF)
val PrimaryFixed = Color(0xFF7DF4FF)
val PrimaryFixedDim = Color(0xFF00DBE9)
val PrimaryContainer = Color(0xFF00F0FF)
val OnPrimary = Color(0xFF00363A)
val OnPrimaryFixed = Color(0xFF002022)
val OnPrimaryFixedVariant = Color(0xFF004F54)
val OnPrimaryContainer = Color(0xFF006970)
val SurfaceTint = Color(0xFF00DBE9)
val InversePrimary = Color(0xFF006970)

// Secondary — neon green accent
val Secondary = Color(0xFFFFFFFF)
val SecondaryFixed = Color(0xFF36FFC4)
val SecondaryFixedDim = Color(0xFF00E1AB)
val SecondaryContainer = Color(0xFF36FFC4)
val OnSecondary = Color(0xFF003828)
val OnSecondaryFixed = Color(0xFF002116)
val OnSecondaryFixedVariant = Color(0xFF00513C)
val OnSecondaryContainer = Color(0xFF007255)

// Tertiary — purple
val Tertiary = Color(0xFFFAF3FF)
val TertiaryFixed = Color(0xFFE9DDFF)
val TertiaryFixedDim = Color(0xFFD1BCFF)
val TertiaryContainer = Color(0xFFE1D2FF)
val OnTertiary = Color(0xFF3C0090)
val OnTertiaryFixed = Color(0xFF23005B)
val OnTertiaryFixedVariant = Color(0xFF5700C9)
val OnTertiaryContainer = Color(0xFF7213FF)

// Error
val Error = Color(0xFFFFB4AB)
val ErrorContainer = Color(0xFF93000A)
val OnError = Color(0xFF690005)
val OnErrorContainer = Color(0xFFFFDAD6)

// Surface hierarchy
val Background = Color(0xFF111317)
val OnBackground = Color(0xFFE2E2E8)
val Surface = Color(0xFF111317)
val OnSurface = Color(0xFFE2E2E8)
val SurfaceDim = Color(0xFF111317)
val SurfaceBright = Color(0xFF37393E)
val SurfaceVariant = Color(0xFF333539)
val OnSurfaceVariant = Color(0xFFB9CACB)
val SurfaceContainerLowest = Color(0xFF0C0E12)
val SurfaceContainerLow = Color(0xFF1A1C20)
val SurfaceContainer = Color(0xFF1E2024)
val SurfaceContainerHigh = Color(0xFF282A2E)
val SurfaceContainerHighest = Color(0xFF333539)
val InverseSurface = Color(0xFFE2E2E8)
val InverseOnSurface = Color(0xFF2F3035)

// Outline
val Outline = Color(0xFF849495)
val OutlineVariant = Color(0xFF3B494B)

// Glassmorphism overlay colors
val GlassBackground = Color(0x991E2024)      // surface-container at 60% opacity
val LiquidGlassBackground = Color(0x731E2024) // surface-container at 45% opacity
val GlassBorderLight = Color(0x1AFFFFFF)     // white at 10% for top/left
val GlassBorderDark = Color(0x33000000)      // black at 20% for bottom/right
val GlowActive = Color(0x4036FFC4)           // secondary-fixed at 25% for box-shadow

// Map pin colors
val PinOpen = SecondaryFixed
val PinFull = Error
val PinLimited = PrimaryFixedDim
