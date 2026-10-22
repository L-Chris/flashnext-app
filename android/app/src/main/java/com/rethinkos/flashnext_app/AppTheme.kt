package com.rethinkos.flashnext_app

import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

// Material Tonal Spot, seed #4F46E5, matching the previous app theme.
private val LightColors = lightColorScheme(
    primary = Color(0xFF5A5892),
    onPrimary = Color(0xFFFFFFFF),
    primaryContainer = Color(0xFFE2DFFF),
    onPrimaryContainer = Color(0xFF424178),
    inversePrimary = Color(0xFFC3C0FF),
    secondary = Color(0xFF5E5C71),
    onSecondary = Color(0xFFFFFFFF),
    secondaryContainer = Color(0xFFE3E0F9),
    onSecondaryContainer = Color(0xFF464559),
    tertiary = Color(0xFF7A5368),
    onTertiary = Color(0xFFFFFFFF),
    tertiaryContainer = Color(0xFFFFD8EA),
    onTertiaryContainer = Color(0xFF603C50),
    background = Color(0xFFFCF8FF),
    onBackground = Color(0xFF1B1B21),
    surface = Color(0xFFFCF8FF),
    onSurface = Color(0xFF1B1B21),
    surfaceVariant = Color(0xFFE4E1EC),
    onSurfaceVariant = Color(0xFF47464F),
    surfaceTint = Color(0xFF5A5892),
    inverseSurface = Color(0xFF313036),
    inverseOnSurface = Color(0xFFF3EFF7),
    error = Color(0xFFBA1A1A),
    onError = Color(0xFFFFFFFF),
    errorContainer = Color(0xFFFFDAD6),
    onErrorContainer = Color(0xFF93000A),
    outline = Color(0xFF787680),
    outlineVariant = Color(0xFFC8C5D0),
    scrim = Color(0xFF000000),
    surfaceBright = Color(0xFFFCF8FF),
    surfaceDim = Color(0xFFDCD9E0),
    surfaceContainer = Color(0xFFF0ECF4),
    surfaceContainerHigh = Color(0xFFEAE7EF),
    surfaceContainerHighest = Color(0xFFE5E1E9),
    surfaceContainerLow = Color(0xFFF6F2FA),
    surfaceContainerLowest = Color(0xFFFFFFFF)
)

private val DarkColors = darkColorScheme(
    primary = Color(0xFFC3C0FF),
    onPrimary = Color(0xFF2B2A60),
    primaryContainer = Color(0xFF424178),
    onPrimaryContainer = Color(0xFFE2DFFF),
    inversePrimary = Color(0xFF5A5892),
    secondary = Color(0xFFC7C4DD),
    onSecondary = Color(0xFF2F2E42),
    secondaryContainer = Color(0xFF464559),
    onSecondaryContainer = Color(0xFFE3E0F9),
    tertiary = Color(0xFFEAB9D1),
    onTertiary = Color(0xFF472639),
    tertiaryContainer = Color(0xFF603C50),
    onTertiaryContainer = Color(0xFFFFD8EA),
    background = Color(0xFF131318),
    onBackground = Color(0xFFE5E1E9),
    surface = Color(0xFF131318),
    onSurface = Color(0xFFE5E1E9),
    surfaceVariant = Color(0xFF47464F),
    onSurfaceVariant = Color(0xFFC8C5D0),
    surfaceTint = Color(0xFFC3C0FF),
    inverseSurface = Color(0xFFE5E1E9),
    inverseOnSurface = Color(0xFF313036),
    error = Color(0xFFFFB4AB),
    onError = Color(0xFF690005),
    errorContainer = Color(0xFF93000A),
    onErrorContainer = Color(0xFFFFDAD6),
    outline = Color(0xFF928F9A),
    outlineVariant = Color(0xFF47464F),
    scrim = Color(0xFF000000),
    surfaceBright = Color(0xFF39383F),
    surfaceDim = Color(0xFF131318),
    surfaceContainer = Color(0xFF201F25),
    surfaceContainerHigh = Color(0xFF2A292F),
    surfaceContainerHighest = Color(0xFF35343A),
    surfaceContainerLow = Color(0xFF1B1B21),
    surfaceContainerLowest = Color(0xFF0E0E13)
)

@Composable fun FlashNextTheme(dark: Boolean, content: @Composable () -> Unit) {
    MaterialTheme(colorScheme = if(dark) DarkColors else LightColors, content = content)
}
