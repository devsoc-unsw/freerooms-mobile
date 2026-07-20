package com.devsoc.freerooms.feature.rooms.data

import android.util.Log
import com.devsoc.freerooms.core.network.GraphQLClient
import com.devsoc.freerooms.core.network.NetworkResult
import com.devsoc.freerooms.core.network.RoomStatusClient
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.core.ui.asResponseState
import com.devsoc.freerooms.feature.rooms.BuildConfig
import com.devsoc.freerooms.network.GetRoomsQuery
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class LiveRoomRepository(
    private val graphQLClient: GraphQLClient,
    private val roomStatusClient: RoomStatusClient,
) : RoomRepository {
    override fun getRooms(): Flow<ResponseState<List<Room>>> {
        return flow {
            if (BuildConfig.DEBUG) {
                Log.d("LiveRoomRepository", "Fetching Rooms...")
            }
            when (val result = graphQLClient.query(GetRoomsQuery())) {
                is NetworkResult.Success -> {
                    if (BuildConfig.DEBUG) {
                        Log.d(
                            "LiveRoomRepository",
                            "Successfully fetched ${result.data.rooms.size} rooms",
                        )
                    }

                    val statuses = when (val statusResult = roomStatusClient.fetchRoomStatus()) {
                        is NetworkResult.Success -> statusResult.data
                        is NetworkResult.Error -> {
                            if (BuildConfig.DEBUG) {
                                Log.e(
                                    "LiveRoomRepository",
                                    "Error fetching room status: ${statusResult.message}",
                                )
                            }
                            emptyMap()
                        }
                    }

                    emit(
                        result.data.rooms.map { room ->
                            val roomStatus = statuses[room.buildingId]
                                ?.roomStatuses
                                ?.get(roomNumberFromId(room.id))

                            Room(
                                id = room.id,
                                seating = room.seating,
                                school = room.school,
                                name = room.name,
                                long = room.long,
                                lat = room.lat,
                                floor = room.floor,
                                capacity = room.capacity,
                                buildingId = room.buildingId,
                                abbr = room.abbr,
                                status = roomAvailabilityFromStatus(roomStatus?.status.orEmpty()),
                                endTime = parseRoomEndTime(roomStatus?.endtime.orEmpty()),
                            )
                        },
                    )
                }

                is NetworkResult.Error -> {
                    if (BuildConfig.DEBUG) {
                        Log.e("LiveRoomRepository", "Error fetching Rooms: ${result.message}")
                    }
                    throw result.exception ?: Exception(result.message)
                }
            }
        }.asResponseState()
    }
}
