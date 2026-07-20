package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.ui.graphics.Color
import com.devsoc.freerooms.core.ui.Gold
import com.devsoc.freerooms.core.ui.Gray3
import com.devsoc.freerooms.core.ui.Green
import com.devsoc.freerooms.core.ui.Red
import com.devsoc.freerooms.feature.rooms.data.RoomAvailability

fun roomStatusColor(status: RoomAvailability): Color = when (status) {
    RoomAvailability.AVAILABLE -> Green
    RoomAvailability.AVAILABLE_SOON -> Gold
    RoomAvailability.UNAVAILABLE -> Red
    RoomAvailability.UNKNOWN -> Gray3
}
