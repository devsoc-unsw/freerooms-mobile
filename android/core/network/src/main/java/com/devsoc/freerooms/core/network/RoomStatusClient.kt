package com.devsoc.freerooms.core.network

interface RoomStatusClient {
    suspend fun fetchRoomStatus(): NetworkResult<RemoteRoomStatus>
}
