package com.devsoc.freerooms.feature.rooms.data

import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

val Room.statusText: String
    get() = when (status) {
        RoomAvailability.AVAILABLE -> {
            val end = endTime
            if (end != null) {
                "Available until ${formatDateTime(end)}"
            } else {
                "Available"
            }
        }
        RoomAvailability.AVAILABLE_SOON -> {
            val end = endTime
            if (end != null) {
                "Available soon at ${formatDateTime(end)}"
            } else {
                "Status unavailable"
            }
        }
        RoomAvailability.UNAVAILABLE -> {
            val end = endTime
            if (end != null) {
                "Unavailable until ${formatDateTime(end)}"
            } else {
                "Unavailable"
            }
        }
        RoomAvailability.UNKNOWN -> "Status unavailable"
    }

private val dateTimeFormatter = DateTimeFormatter
    .ofPattern("dd/MM HH:mm", Locale.US)
    .withZone(ZoneId.systemDefault())

private fun formatDateTime(instant: Instant): String = dateTimeFormatter.format(instant)
