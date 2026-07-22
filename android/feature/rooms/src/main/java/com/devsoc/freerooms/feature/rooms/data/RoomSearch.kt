package com.devsoc.freerooms.feature.rooms.data

fun List<Room>.filterBySearchQuery(query: String): List<Room> {
    val loweredQuery = query.trim().lowercase()
    if (loweredQuery.isEmpty()) return this

    return filter { room ->
        room.name.lowercase().contains(loweredQuery) ||
            room.abbr.lowercase().contains(loweredQuery)
    }
}
