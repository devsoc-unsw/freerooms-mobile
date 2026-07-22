package com.devsoc.freerooms.feature.rooms.data

import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

fun Room.statusText(use12HourClock: Boolean = false): String = when (status) {
    RoomAvailability.AVAILABLE -> {
        val end = endTime
        if (end != null) {
            "Available until ${formatDateTime(end, use12HourClock)}"
        } else {
            "Available"
        }
    }
    RoomAvailability.AVAILABLE_SOON -> {
        val end = endTime
        if (end != null) {
            "Available soon at ${formatDateTime(end, use12HourClock)}"
        } else {
            "Status unavailable"
        }
    }
    RoomAvailability.UNAVAILABLE -> {
        val end = endTime
        if (end != null) {
            "Unavailable until ${formatDateTime(end, use12HourClock)}"
        } else {
            "Unavailable"
        }
    }
    RoomAvailability.UNKNOWN -> "Status unavailable"
}

private val dateTime24Formatter = DateTimeFormatter
    .ofPattern("dd/MM HH:mm", Locale.US)
    .withZone(ZoneId.systemDefault())

private val dateTime12Formatter = DateTimeFormatter
    .ofPattern("dd/MM h:mm a", Locale.US)
    .withZone(ZoneId.systemDefault())

private fun formatDateTime(instant: Instant, use12HourClock: Boolean): String {
    val formatter = if (use12HourClock) dateTime12Formatter else dateTime24Formatter
    return formatter.format(instant)
}
