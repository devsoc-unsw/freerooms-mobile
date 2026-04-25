package com.devsoc.freerooms.features.buildings.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.features.buildings.data.Building
import com.devsoc.freerooms.features.buildings.data.BuildingRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import org.koin.android.annotation.KoinViewModel

@KoinViewModel
class BuildingViewModel(
    private val repository: BuildingRepository
) : ViewModel() {

    val uiState: StateFlow<ResponseState<List<Building>>> = repository
        .getBuildings()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = ResponseState.Loading
        )
}
