package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.unit.dp
import java.time.format.DateTimeFormatter
import java.util.Locale

internal val BookingsBoxShape = RoundedCornerShape(12.dp)
internal val BookingsDateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.US)
internal val BookingsTime24Formatter = DateTimeFormatter.ofPattern("HH:mm", Locale.US)
internal val BookingsTime12Formatter = DateTimeFormatter.ofPattern("h:mm a", Locale.US)
internal val TimelineHours = 9..23
internal val SlotHeight = 60.dp
internal val TimeColumnWidth = 64.dp
internal val ThickLine = 2.dp
internal val ThinLine = 1.dp
internal val TimelineStartHour = 9
internal val TimelineEndHour = 24

internal fun formatBookingTime(time: java.time.LocalTime, use12HourClock: Boolean): String {
    return time.format(if (use12HourClock) BookingsTime12Formatter else BookingsTime24Formatter)
}

internal fun formatHourLabel(hour: Int, use12HourClock: Boolean): String {
    if (!use12HourClock) {
        return String.format(Locale.US, "%02d:00", hour)
    }
    val displayHour = when {
        hour == 0 || hour == 12 -> 12
        hour > 12 -> hour - 12
        else -> hour
    }
    val period = if (hour < 12) "AM" else "PM"
    return String.format(Locale.US, "%d %s", displayHour, period)
}
