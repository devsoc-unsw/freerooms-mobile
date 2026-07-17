package com.devsoc.freerooms.feature.buildings.data

import android.util.Log
import com.devsoc.freerooms.core.network.GraphQLClient
import com.devsoc.freerooms.core.network.NetworkResult
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.core.ui.asResponseState
import com.devsoc.freerooms.feature.buildings.BuildConfig
import com.devsoc.freerooms.network.GetBuildingsQuery
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class LiveBuildingRepository(private val graphQLClient: GraphQLClient) : BuildingRepository {
    override fun getBuildings(): Flow<ResponseState<List<Building>>> {
        return flow {
            if (BuildConfig.DEBUG) {
                Log.d("LiveBuildingRepository", "Fetching buildings...")
            }
            when (val result = graphQLClient.query(GetBuildingsQuery())) {
                is NetworkResult.Success -> {
                    if (BuildConfig.DEBUG) {
                        Log.d(
                            "LiveBuildingRepository",
                            "Successfully fetched ${result.data.buildings.size} buildings"
                        )
                    }
                    emit(result.data)
                }
                is NetworkResult.Error -> {
                    if (BuildConfig.DEBUG) {
                        Log.e("LiveBuildingRepository", "Error fetching buildings: ${result.message}")
                    }
                    throw result.exception ?: Exception(result.message)
                }
            }
        }.asResponseState { data ->
            data.buildings.map {
                Building(
                    id = it.id,
                    name = it.name,
                    lat = it.lat,
                    long = it.long
                )
            }
        }
    }
}
