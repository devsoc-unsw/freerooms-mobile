package com.devsoc.freerooms.features.buildings.ui

import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.devsoc.freerooms.core.ui.ResponseState
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun BuildingScreen(viewModel: BuildingViewModel = koinViewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    when (val state = uiState) {
        is ResponseState.Loading -> Text("Loading...")
        is ResponseState.Error -> Text("Error: ${state.exception.message}")
        is ResponseState.Success -> {
            LazyColumn {
                items(state.data) { building ->
                    Text(building.name)
                }
            }
        }
    }
}
