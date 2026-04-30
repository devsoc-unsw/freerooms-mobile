package com.devsoc.freerooms.feature.buildings.data

import com.devsoc.freerooms.core.ui.ResponseState
import kotlinx.coroutines.flow.Flow

interface BuildingRepository {
    fun getBuildings(): Flow<ResponseState<List<Building>>>
}
