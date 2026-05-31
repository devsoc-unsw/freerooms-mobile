package com.devsoc.freerooms.navigation

import com.devsoc.freerooms.core.ui.FreeroomsPage

internal object FreeroomsRoute {
    const val Buildings = "buildings"
    const val Rooms = "rooms"
    const val Map = "map"
}

internal val FreeroomsPage.route: String
    get() = when (this) {
        FreeroomsPage.Building -> FreeroomsRoute.Buildings
        FreeroomsPage.Rooms -> FreeroomsRoute.Rooms
        FreeroomsPage.Map -> FreeroomsRoute.Map
    }

internal fun String?.toFreeroomsPage(): FreeroomsPage {
    return when (this) {
        FreeroomsRoute.Rooms -> FreeroomsPage.Rooms
        FreeroomsRoute.Map -> FreeroomsPage.Map
        else -> FreeroomsPage.Building
    }
}
