package com.devsoc.freerooms.feature.rooms.data

import java.time.Instant

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
        get() = roomNumberFromId(id)
}
