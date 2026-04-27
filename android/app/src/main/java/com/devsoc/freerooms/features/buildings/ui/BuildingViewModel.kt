package com.devsoc.freerooms.features.buildings.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProvider.AndroidViewModelFactory.Companion.APPLICATION_KEY
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.devsoc.freerooms.MainApplication
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.features.buildings.data.Building
import com.devsoc.freerooms.features.buildings.data.BuildingRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

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

    companion object {
        val Factory: ViewModelProvider.Factory = viewModelFactory {
            initializer {
                val application = (this[APPLICATION_KEY] as MainApplication)
                val repository = application.appContainer.buildingRepository
                BuildingViewModel(repository = repository)
            }
        }
    }
}
