package com.devsoc.freerooms.feature.map.ui

import com.devsoc.freerooms.core.ui.Red
import com.devsoc.freerooms.core.ui.Gold
import com.devsoc.freerooms.core.ui.Lime
import androidx.compose.ui.graphics.Color

fun capacityColour(count: Int?): Color {
    val available = count ?: 0
    return if (available == 0) {
        Red
    } else if (available < 5) {
        Gold
    } else {
        Lime
    }
}