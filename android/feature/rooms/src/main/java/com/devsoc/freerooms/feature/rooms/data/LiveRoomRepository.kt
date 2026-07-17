package com.devsoc.freerooms.feature.rooms.data

import android.util.Log
import com.devsoc.freerooms.core.network.GraphQLClient
import com.devsoc.freerooms.core.network.NetworkResult
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.core.ui.asResponseState
import com.devsoc.freerooms.feature.rooms.BuildConfig
import com.devsoc.freerooms.network.GetRoomsQuery
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class LiveRoomRepository(private val graphQLClient: GraphQLClient) : RoomRepository {
//    private var allRooms: List<Room> = emptyList<Room>();
//    private val cachedRooms: MutableMap<String,List<Room>> = mutableMapOf<String,List<Room>>();

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
                            "Successfully fetched ${result.data.rooms.size} rooms"
                        )
                    }
                    emit(result.data)
                }

                is NetworkResult.Error -> {
                    if (BuildConfig.DEBUG) {
                        Log.e("LiveRoomRepository", "Error fetching Rooms: ${result.message}")
                    }
                    throw result.exception ?: Exception(result.message)
                }
            }
        }.asResponseState { data ->
            data.rooms.map {
                Room(
                    id = it.id,
                    seating = it.seating,
                    school = it.school,
                    name = it.name,
                    long = it.long,
                    lat = it.lat,
                    floor = it.floor,
                    capacity = it.capacity,
                    buildingId = it.buildingId,
                    abbr = it.abbr
                )
            }
        }
    }

//    init {
//        allRooms = cacheRooms().toList();
//
//        for (room in allRooms) {
//            if (cachedRooms.containsKey(room.buildingId)) {
//                cachedRooms[room.buildingId]?.plus(room)?.let { cachedRooms.put(room.buildingId, it) };
//            } else {
//                cachedRooms[room.buildingId] = listOf(room);
//            }
//
//        };
//    }
//
//    override fun getRooms(): List<Room> {
//        return allRooms;
//    }
//
//    override fun getRooms(buildingName: String): List<Room> {
//        return cachedRooms[buildingName]?:emptyList<Room>();
//    }
}