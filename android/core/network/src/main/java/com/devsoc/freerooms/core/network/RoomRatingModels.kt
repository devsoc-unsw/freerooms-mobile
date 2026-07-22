package com.devsoc.freerooms.core.network

data class RemoteAverageRating(
    val cleanliness: Double,
    val location: Double,
    val quietness: Double,
)

data class RemoteRoomRating(
    val roomId: String,
    val overallRating: Double,
    val averageRating: RemoteAverageRating,
)
