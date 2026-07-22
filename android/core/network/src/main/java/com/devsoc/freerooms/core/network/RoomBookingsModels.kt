package com.devsoc.freerooms.core.network

data class RemoteRoomBooking(
    val name: String,
    val bookingType: String,
    val start: String,
    val end: String,
)

data class RemoteRoomBookings(
    val id: String,
    val name: String,
    val bookings: List<RemoteRoomBooking>,
)
