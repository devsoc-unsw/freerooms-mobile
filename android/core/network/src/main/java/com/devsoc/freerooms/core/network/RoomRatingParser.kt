package com.devsoc.freerooms.core.network

import org.json.JSONObject

fun parseRoomRating(json: String): RemoteRoomRating {
    val root = JSONObject(json)
    val averageJson = root.optJSONObject("averageRating") ?: JSONObject()

    return RemoteRoomRating(
        roomId = root.optString("roomId", ""),
        overallRating = root.optDouble("overallRating", 0.0),
        averageRating = RemoteAverageRating(
            cleanliness = averageJson.optDouble("cleanliness", 0.0),
            location = averageJson.optDouble("location", 0.0),
            quietness = averageJson.optDouble("quietness", 0.0),
        ),
    )
}
