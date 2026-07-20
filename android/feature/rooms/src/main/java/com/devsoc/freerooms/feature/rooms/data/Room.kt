package com.devsoc.freerooms.feature.rooms.data

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
)