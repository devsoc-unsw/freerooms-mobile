package com.devsoc.freerooms.feature.buildings.data

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.devsoc.freerooms.core.ui.ResponseState
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class BuildingViewModel(private val repository: BuildingRepository) : ViewModel() {

    val uiState: StateFlow<ResponseState<List<Building>>> =
        repository
            .getBuildings()
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = ResponseState.Loading
            )
}
