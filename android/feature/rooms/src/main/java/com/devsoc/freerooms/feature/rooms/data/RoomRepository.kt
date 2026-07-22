package com.devsoc.freerooms.feature.rooms.data

import com.devsoc.freerooms.core.ui.ResponseState
import kotlinx.coroutines.flow.Flow

interface RoomRepository {
    fun getRooms(): Flow<ResponseState<List<Room>>>
    fun getBookings(roomId: String): Flow<ResponseState<List<RoomBooking>>>
    fun getRating(roomId: String): Flow<ResponseState<RoomRating>>
}