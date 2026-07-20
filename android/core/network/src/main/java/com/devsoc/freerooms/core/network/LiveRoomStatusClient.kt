package com.devsoc.freerooms.core.network

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request

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
}
