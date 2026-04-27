package com.devsoc.freerooms.features.buildings.ui

import android.util.Log
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.devsoc.freerooms.core.ui.ResponseState

@Composable
fun BuildingScreen(
    viewModel: BuildingViewModel = viewModel(factory = BuildingViewModel.Factory)
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(uiState) {
        Log.d("BuildingScreen", "UI State: $uiState")
    }

    when (val state = uiState) {
        is ResponseState.Loading -> Text("Loading...")
        is ResponseState.Error -> {
            Log.e("BuildingScreen", "Displaying Error: ${state.exception.message}", state.exception)
            Text("Error: ${state.exception.message}")
        }
        is ResponseState.Success -> {
            LazyColumn {
                items(state.data) { building ->
                    Text(building.name)
                }
            }
        }
    }
}
