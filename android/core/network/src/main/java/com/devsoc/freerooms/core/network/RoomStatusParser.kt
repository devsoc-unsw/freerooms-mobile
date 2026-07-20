package com.devsoc.freerooms.core.network

import org.json.JSONObject

fun parseRoomStatus(json: String): RemoteRoomStatus {
    val root = JSONObject(json)
    val result = linkedMapOf<String, BuildingRoomStatus>()
    val buildingIds = root.keys()

    while (buildingIds.hasNext()) {
        val buildingId = buildingIds.next()
        val buildingJson = root.getJSONObject(buildingId)
        val numAvailable = buildingJson.optInt("numAvailable", 0)
        val roomStatusesJson = buildingJson.optJSONObject("roomStatuses") ?: JSONObject()
        val roomStatuses = linkedMapOf<String, RoomStatusEntry>()
        val roomNumbers = roomStatusesJson.keys()

        while (roomNumbers.hasNext()) {
            val roomNumber = roomNumbers.next()
            val roomJson = roomStatusesJson.getJSONObject(roomNumber)
            roomStatuses[roomNumber] = RoomStatusEntry(
                status = roomJson.optString("status", ""),
                endtime = roomJson.optString("endtime", ""),
            )
        }

        result[buildingId] = BuildingRoomStatus(
            numAvailable = numAvailable,
            roomStatuses = roomStatuses,
        )
    }

    return result
}
