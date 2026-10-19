package com.airback.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

// AirBack brand: near-black ground, amber accent, cool grey text. One scheme on every device;
// TVs have no light mode worth supporting and dynamic color would wash the brand out.
val Ground = Color(0xFF05070D)
val Amber = Color(0xFFF59E0B)
private val Surface1 = Color(0xFF0D1220)
private val Surface2 = Color(0xFF131A2B)
private val Surface3 = Color(0xFF1A2236)
private val Ink = Color(0xFFE6E8EE)
private val InkMuted = Color(0xFF9AA3B5)
private val Line = Color(0xFF2A3347)

private val AirBackColors = darkColorScheme(
    primary = Amber,
    onPrimary = Color(0xFF1A1200),
    primaryContainer = Color(0xFF3B2A06),
    onPrimaryContainer = Color(0xFFFFE2B0),
    secondary = InkMuted,
    onSecondary = Ground,
    secondaryContainer = Surface3,
    onSecondaryContainer = Ink,
    tertiary = Amber,
    onTertiary = Color(0xFF1A1200),
    tertiaryContainer = Surface3,
    onTertiaryContainer = Ink,
    background = Ground,
    onBackground = Ink,
    surface = Ground,
    onSurface = Ink,
    surfaceVariant = Surface2,
    onSurfaceVariant = InkMuted,
    surfaceContainerLowest = Ground,
    surfaceContainerLow = Surface1,
    surfaceContainer = Surface1,
    surfaceContainerHigh = Surface2,
    surfaceContainerHighest = Surface3,
    inverseSurface = Ink,
    inverseOnSurface = Ground,
    outline = Line,
    outlineVariant = Color(0xFF1F2638),
    error = Color(0xFFFF6B57),
    onError = Ground,
    errorContainer = Color(0xFF4A1A12),
    onErrorContainer = Color(0xFFFFD9D2),
)

@Composable
fun AirPlayTheme(
    darkTheme: Boolean = true,
    content: @Composable () -> Unit
) {
    MaterialTheme(colorScheme = AirBackColors, content = content)
}
