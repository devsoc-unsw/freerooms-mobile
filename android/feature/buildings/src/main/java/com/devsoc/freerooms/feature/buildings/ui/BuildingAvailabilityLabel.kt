package com.devsoc.freerooms.feature.buildings.ui

fun availableRoomsLabel(count: Int?): String {
    val available = count ?: 0
    return if (available == 1) {
        "1 room available"
    } else {
        "$available rooms available"
    }
}
