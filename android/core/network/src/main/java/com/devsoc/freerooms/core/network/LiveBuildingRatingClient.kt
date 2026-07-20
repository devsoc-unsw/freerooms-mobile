package com.devsoc.freerooms.core.network

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject

class LiveBuildingRatingClient(
    private val okHttpClient: OkHttpClient,
    private val baseUrl: String = NetworkConstants.REST_BASE_URL,
) : BuildingRatingClient {
    override suspend fun fetch(buildingId: String): NetworkResult<Double> {
        return withContext(Dispatchers.IO) {
            try {
                val request = Request.Builder()
                    .url("$baseUrl/api/buildingRating/$buildingId")
                    .get()
                    .build()

                okHttpClient.newCall(request).execute().use { response ->
                    if (!response.isSuccessful) {
                        return@withContext NetworkResult.Error("HTTP ${response.code}")
                    }

                    val body = response.body?.string()
                        ?: return@withContext NetworkResult.Error("Empty response body")

                    val overallRating = JSONObject(body).optDouble("overallRating", Double.NaN)
                    if (overallRating.isNaN()) {
                        NetworkResult.Error("Missing overallRating")
                    } else {
                        NetworkResult.Success(overallRating)
                    }
                }
            } catch (e: Exception) {
                Log.e("LiveBuildingRatingClient", "Failed to fetch rating for $buildingId", e)
                NetworkResult.Error(e.message ?: "Unknown error", e)
            }
        }
    }
}
