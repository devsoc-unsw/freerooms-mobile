package com.devsoc.freerooms.core.network

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request

class LiveRoomRatingClient(
    private val okHttpClient: OkHttpClient,
    private val baseUrl: String = NetworkConstants.REST_BASE_URL,
) : RoomRatingClient {
    override suspend fun fetchRoomRating(roomId: String): NetworkResult<RemoteRoomRating> {
        return withContext(Dispatchers.IO) {
            try {
                val request = Request.Builder()
                    .url("$baseUrl/api/rating/$roomId")
                    .get()
                    .build()

                okHttpClient.newCall(request).execute().use { response ->
                    if (!response.isSuccessful) {
                        return@withContext NetworkResult.Error("HTTP ${response.code}")
                    }

                    val body = response.body?.string()
                        ?: return@withContext NetworkResult.Error("Empty response body")

                    NetworkResult.Success(parseRoomRating(body))
                }
            } catch (e: Exception) {
                Log.e("LiveRoomRatingClient", "Failed to fetch room rating", e)
                NetworkResult.Error(e.message ?: "Unknown error", e)
            }
        }
    }
}
