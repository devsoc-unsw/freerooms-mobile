package com.devsoc.freerooms.feature.rooms.data

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.devsoc.freerooms.core.ui.ResponseState
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import java.util.concurrent.ConcurrentHashMap

class RoomViewModel(private val repository: RoomRepository) : ViewModel() {

    val uiState: StateFlow<ResponseState<List<Room>>> =
        repository
            .getRooms()
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = ResponseState.Loading,
            )

    private val bookingsByRoomId =
        ConcurrentHashMap<String, StateFlow<ResponseState<List<RoomBooking>>>>()

    private val ratingsByRoomId =
        ConcurrentHashMap<String, StateFlow<ResponseState<RoomRating>>>()

    fun bookingsFor(roomId: String): StateFlow<ResponseState<List<RoomBooking>>> {
        return bookingsByRoomId.getOrPut(roomId) {
            repository
                .getBookings(roomId)
                .stateIn(
                    scope = viewModelScope,
                    started = SharingStarted.WhileSubscribed(5000),
                    initialValue = ResponseState.Loading,
                )
        }
    }

    fun ratingFor(roomId: String): StateFlow<ResponseState<RoomRating>> {
        return ratingsByRoomId.getOrPut(roomId) {
            repository
                .getRating(roomId)
                .stateIn(
                    scope = viewModelScope,
                    started = SharingStarted.WhileSubscribed(5000),
                    initialValue = ResponseState.Loading,
                )
        }
    }
}
