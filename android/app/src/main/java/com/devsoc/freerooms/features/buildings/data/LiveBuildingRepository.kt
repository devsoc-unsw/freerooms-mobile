package com.devsoc.freerooms.features.buildings.data

import com.devsoc.freerooms.GetBuildingsQuery
import com.devsoc.freerooms.core.network.GraphQLClient
import com.devsoc.freerooms.core.network.NetworkResult
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.core.ui.asResponseState
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import org.koin.core.annotation.Single

@Single(binds = [BuildingRepository::class])
class LiveBuildingRepository(private val graphQLClient: GraphQLClient): BuildingRepository {
    override fun getBuildings(): Flow<ResponseState<List<Building>>> {
        return flow {
            when (val result = graphQLClient.query(GetBuildingsQuery())) {
                is NetworkResult.Success -> emit(result.data)
                is NetworkResult.Error -> throw result.exception ?: Exception(result.message)
            }
        }.asResponseState { data ->
            data.buildings.map {
                Building(
                    id = it.id,
                    name = it.name,
                    lat = it.lat,
                    long = it.long,
                    aliases = it.aliases
                )
            }
        }
    }
}
