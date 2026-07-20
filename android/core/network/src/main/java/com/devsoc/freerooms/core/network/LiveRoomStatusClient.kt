package com.devsoc.freerooms.core.network

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject

class LiveRoomStatusClient(
    private val okHttpClient: OkHttpClient,
    private val baseUrl: String = NetworkConstants.REST_BASE_URL,
) : RoomStatusClient {
    override suspend fun fetchRoomStatus(): NetworkResult<RemoteRoomStatus> {
        return withContext(Dispatchers.IO) {
            try {
                val request = Request.Builder()
                    .url("$baseUrl/api/rooms/status")
                    .get()
                    .build()

                okHttpClient.newCall(request).execute().use { response ->
                    if (!response.isSuccessful) {
                        return@withContext NetworkResult.Error("HTTP ${response.code}")
                    }

                    val body = response.body?.string()
                        ?: return@withContext NetworkResult.Error("Empty response body")

                    NetworkResult.Success(parseRoomStatus(body))
                }
            } catch (e: Exception) {
                Log.e("LiveRoomStatusClient", "Failed to fetch room status", e)
                NetworkResult.Error(e.message ?: "Unknown error", e)
            }
        }
    }

    companion object {
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
    }
}
