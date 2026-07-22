package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.devsoc.freerooms.feature.rooms.data.RoomAvailability

@Composable
fun roomStatusColor(status: RoomAvailability): Color {
    val colors = MaterialTheme.colorScheme
    return when (status) {
        RoomAvailability.AVAILABLE -> colors.tertiary
        RoomAvailability.AVAILABLE_SOON -> colors.secondary
        RoomAvailability.UNAVAILABLE -> colors.error
        RoomAvailability.UNKNOWN -> colors.onSurfaceVariant
    }
}
