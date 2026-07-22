package com.devsoc.freerooms.feature.rooms.data

data class RoomRating(
    val roomId: String,
    val overallRating: Double,
    val cleanliness: Double,
    val location: Double,
    val quietness: Double,
)
