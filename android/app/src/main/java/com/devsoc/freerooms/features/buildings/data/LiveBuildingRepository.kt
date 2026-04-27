package com.devsoc.freerooms.features.buildings.data

import android.util.Log
import com.devsoc.freerooms.GetBuildingsQuery
import com.devsoc.freerooms.core.network.GraphQLClient
import com.devsoc.freerooms.core.network.NetworkResult
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.core.ui.asResponseState
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class LiveBuildingRepository(private val graphQLClient: GraphQLClient): BuildingRepository {
    override fun getBuildings(): Flow<ResponseState<List<Building>>> {
        return flow {
            Log.d("LiveBuildingRepository", "Fetching buildings...")
            when (val result = graphQLClient.query(GetBuildingsQuery())) {
                is NetworkResult.Success -> {
                    Log.d("LiveBuildingRepository", "Successfully fetched ${result.data.buildings.size} buildings")
                    emit(result.data)
                }
                is NetworkResult.Error -> {
                    Log.e("LiveBuildingRepository", "Error fetching buildings: ${result.message}")
                    throw result.exception ?: Exception(result.message)
                }
            }
        }.asResponseState { data ->
            data.buildings.map {
                Building(
                    id = it.id,
                    name = it.name,
                    lat = it.lat,
                    long = it.long,
                )
            }
        }
    }
}
