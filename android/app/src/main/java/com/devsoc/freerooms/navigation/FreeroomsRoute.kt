package com.devsoc.freerooms.navigation

import android.net.Uri
import com.devsoc.freerooms.core.ui.FreeroomsPage

internal object FreeroomsRoute {
    const val Buildings = "buildings"
    const val BuildingRooms = "buildings/{buildingId}"
    const val Rooms = "rooms"
    const val RoomDetails = "rooms/{roomId}"
    const val Map = "map"

    fun buildingRooms(buildingId: String): String {
        return "buildings/${Uri.encode(buildingId)}"
    }

    fun roomDetails(roomId: String): String {
        return "rooms/${Uri.encode(roomId)}"
    }
}

internal val FreeroomsPage.route: String
    get() = when (this) {
        FreeroomsPage.Building -> FreeroomsRoute.Buildings
        FreeroomsPage.Rooms -> FreeroomsRoute.Rooms
        FreeroomsPage.Map -> FreeroomsRoute.Map
    }

internal fun String?.toFreeroomsPage(): FreeroomsPage {
    return when (this) {
        FreeroomsRoute.Rooms,
        FreeroomsRoute.RoomDetails,
        -> FreeroomsPage.Rooms
        FreeroomsRoute.Map -> FreeroomsPage.Map
        FreeroomsRoute.Buildings,
        FreeroomsRoute.BuildingRooms,
        -> FreeroomsPage.Building
        else -> FreeroomsPage.Building
    }
}

internal fun String?.hidesBottomBar(): Boolean {
    return this == FreeroomsRoute.BuildingRooms || this == FreeroomsRoute.RoomDetails
}

internal fun String?.isRoomDetailsRoute(): Boolean {
    return this == FreeroomsRoute.RoomDetails
}
