package com.devsoc.freerooms

import android.app.Application
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.devsoc.freerooms.feature.buildings.data.BuildingViewModel

class MainApplication : Application() {
    val appContainer = AppContainer()

    companion object {
        val BuildingViewModelFactory = viewModelFactory {
            initializer {
                val application = (this[ViewModelProvider.AndroidViewModelFactory.APPLICATION_KEY] as MainApplication)
                val repository = application.appContainer.buildingRepository
                BuildingViewModel(repository = repository)
            }
        }
    }
}
