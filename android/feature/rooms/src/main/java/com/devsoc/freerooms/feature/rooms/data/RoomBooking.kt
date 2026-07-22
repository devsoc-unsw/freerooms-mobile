package com.devsoc.freerooms.feature.rooms.data

import java.time.Instant

data class RoomBooking(
    val name: String,
    val start: Instant,
    val end: Instant,
)
