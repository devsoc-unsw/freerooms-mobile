package com.devsoc.freerooms.core.network

interface RoomBookingsClient {
    suspend fun fetchRoomBookings(roomId: String): NetworkResult<RemoteRoomBookings>
}
