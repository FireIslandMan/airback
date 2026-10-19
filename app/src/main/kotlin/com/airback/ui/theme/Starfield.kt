package com.airback.ui.theme

import androidx.compose.foundation.Canvas
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color

// Sparse, fixed starfield behind the app's screens. Deterministic so it never twinkles or shifts
// between recompositions; density is per area so phones and TVs look the same.
@Composable
fun Starfield(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        drawRect(Ground)
        var seed = 0x9E3779B97F4A7C15uL
        fun next(): Float {
            seed = seed * 6364136223846793005uL + 1442695040888963407uL
            return ((seed shr 33) % 10000uL).toFloat() / 10000f
        }
        val count = ((size.width * size.height) / (density * density * 2600f)).toInt().coerceIn(40, 400)
        repeat(count) {
            val x = next() * size.width
            val y = next() * size.height
            val r = (0.5f + next() * 1.1f) * density
            val a = 0.22f + next() * 0.55f
            drawCircle(Color.White.copy(alpha = a), radius = r, center = Offset(x, y))
        }
    }
}
