package com.devsoc.freerooms.core.network

interface RoomRatingClient {
    suspend fun fetchRoomRating(roomId: String): NetworkResult<RemoteRoomRating>
}
