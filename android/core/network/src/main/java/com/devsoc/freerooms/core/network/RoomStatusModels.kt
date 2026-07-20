package com.devsoc.freerooms.core.network

data class RoomStatusEntry(
    val status: String,
    val endtime: String,
)

data class BuildingRoomStatus(
    val numAvailable: Int,
    val roomStatuses: Map<String, RoomStatusEntry>,
)

typealias RemoteRoomStatus = Map<String, BuildingRoomStatus>
