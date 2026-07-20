package com.devsoc.freerooms.feature.rooms.data

import java.time.Instant
import java.time.OffsetDateTime

fun roomNumberFromId(roomId: String): String {
    val parts = roomId.split("-")
    return if (parts.size == 3) parts[2] else "?"
}

fun parseRoomEndTime(value: String): Instant? {
    if (value.isBlank()) return null
    return runCatching { Instant.parse(value) }.getOrNull()
        ?: runCatching { OffsetDateTime.parse(value).toInstant() }.getOrNull()
}

fun roomAvailabilityFromStatus(status: String): RoomAvailability = when (status) {
    "free" -> RoomAvailability.AVAILABLE
    "soon" -> RoomAvailability.AVAILABLE_SOON
    "busy" -> RoomAvailability.UNAVAILABLE
    else -> RoomAvailability.UNKNOWN
}
