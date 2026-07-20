package com.devsoc.freerooms.feature.rooms.data

import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

enum class RoomAvailability {
    AVAILABLE,
    AVAILABLE_SOON,
    UNAVAILABLE,
    UNKNOWN,
}

data class Room(
    val seating: String?,
    val school: String,
    val name: String,
    val long: Double,
    val lat: Double,
    val id: String,
    val floor: String?,
    val capacity: Int,
    val buildingId: String,
    val abbr: String,
    val overallRating: Double? = null,
    val status: RoomAvailability = RoomAvailability.UNKNOWN,
    val endTime: Instant? = null,
) {
    val roomNumber: String
        get() {
            val parts = id.split("-")
            return if (parts.size == 3) parts[2] else "?"
        }

    val statusText: String
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

    companion object {
        private val dateTimeFormatter = DateTimeFormatter
            .ofPattern("dd/MM HH:mm", Locale.US)
            .withZone(ZoneId.systemDefault())

        private fun formatDateTime(instant: Instant): String = dateTimeFormatter.format(instant)

        fun parseEndTime(value: String): Instant? {
            if (value.isBlank()) return null
            return runCatching { Instant.parse(value) }.getOrNull()
                ?: runCatching { java.time.OffsetDateTime.parse(value).toInstant() }.getOrNull()
        }

        fun availabilityFromStatus(status: String): RoomAvailability = when (status) {
            "free" -> RoomAvailability.AVAILABLE
            "soon" -> RoomAvailability.AVAILABLE_SOON
            "busy" -> RoomAvailability.UNAVAILABLE
            else -> RoomAvailability.UNKNOWN
        }
    }
}
