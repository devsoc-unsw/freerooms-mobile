package com.devsoc.freerooms.feature.buildings.data

fun List<Building>.filterBySearchQuery(query: String): List<Building> {
    val loweredQuery = query.trim().lowercase()
    if (loweredQuery.isEmpty()) return this

    return filter { building ->
        building.name.lowercase().contains(loweredQuery) ||
            building.aliases.any { alias -> alias.lowercase().contains(loweredQuery) }
    }
}
