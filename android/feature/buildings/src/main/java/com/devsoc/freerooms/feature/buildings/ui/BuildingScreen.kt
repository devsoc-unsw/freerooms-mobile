package com.devsoc.freerooms.feature.buildings.ui

import android.util.Log
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.feature.buildings.data.BuildingViewModel

@Composable
fun BuildingScreen(
    viewModel: BuildingViewModel,
    modifier: Modifier = Modifier,
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(uiState) { Log.d("BuildingScreen", "UI State: $uiState") }

    when (val state = uiState) {
        is ResponseState.Loading -> Text("Loading...", modifier = modifier)
        is ResponseState.Error -> {
            Log.e("BuildingScreen", "Displaying Error: ${state.exception.message}", state.exception)
            Text("Error: ${state.exception.message}", modifier = modifier)
        }
        is ResponseState.Success -> {
            LazyColumn(modifier = modifier) {
                items(state.data) { building -> Text(building.name) }
            }
        }
    }
}
