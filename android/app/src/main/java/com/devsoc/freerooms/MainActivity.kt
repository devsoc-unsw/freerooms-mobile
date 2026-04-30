package com.devsoc.freerooms

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import com.devsoc.freerooms.core.ui.FreeroomsTheme
import com.devsoc.freerooms.feature.buildings.ui.BuildingScreen

class MainActivity : ComponentActivity() {

    private val buildingViewModel by viewModels<com.devsoc.freerooms.feature.buildings.data.BuildingViewModel> {
        MainApplication.BuildingViewModelFactory
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            FreeroomsTheme {
                BuildingScreen(viewModel = buildingViewModel)
            }
        }
    }
}
