package com.devsoc.freerooms.feature.buildings.data

import android.util.Log
import com.devsoc.freerooms.core.network.GraphQLClient
import com.devsoc.freerooms.core.network.NetworkResult
import com.devsoc.freerooms.core.network.RoomStatusClient
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.core.ui.asResponseState
import com.devsoc.freerooms.feature.buildings.BuildConfig
import com.devsoc.freerooms.network.GetBuildingsQuery
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class LiveBuildingRepository(
    private val graphQLClient: GraphQLClient,
    private val roomStatusClient: RoomStatusClient,
) : BuildingRepository {
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
                            "Successfully fetched ${result.data.buildings.size} buildings",
                        )
                    }

                    val statuses = when (val statusResult = roomStatusClient.fetchRoomStatus()) {
                        is NetworkResult.Success -> statusResult.data
                        is NetworkResult.Error -> {
                            if (BuildConfig.DEBUG) {
                                Log.e(
                                    "LiveBuildingRepository",
                                    "Error fetching room status: ${statusResult.message}",
                                )
                            }
                            emptyMap()
                        }
                    }

                    emit(
                        result.data.buildings.map { building ->
                            Building(
                                id = building.id,
                                name = building.name,
                                lat = building.lat,
                                long = building.long,
                                numberOfAvailableRooms = statuses[building.id]?.numAvailable,
                            )
                        },
                    )
                }
                is NetworkResult.Error -> {
                    if (BuildConfig.DEBUG) {
                        Log.e("LiveBuildingRepository", "Error fetching buildings: ${result.message}")
                    }
                    throw result.exception ?: Exception(result.message)
                }
            }
        }.asResponseState()
    }
}
