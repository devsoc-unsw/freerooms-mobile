package com.devsoc.freerooms.core.network

interface BuildingRatingClient {
    suspend fun fetch(buildingId: String): NetworkResult<Double>
}
