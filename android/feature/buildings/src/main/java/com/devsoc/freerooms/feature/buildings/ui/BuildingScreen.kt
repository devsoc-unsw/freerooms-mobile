package com.devsoc.freerooms.feature.buildings.ui

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.feature.buildings.data.Building
import com.devsoc.freerooms.feature.buildings.data.BuildingViewModel
import com.devsoc.freerooms.feature.buildings.data.CampusSection

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
            val buildingSections = state.data.toBuildingSections()

            LazyColumn(
                modifier = modifier.background(Gray),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                items(
                    items = buildingSections,
                    key = { section -> section.title },
                ) { section ->
                    BuildingSectionCard(
                        title = section.title,
                        buildings = section.buildings,
                    )
                }
            }
        }
    }
}

private data class BuildingSection(
    val title: String,
    val buildings: List<Building>,
)

private fun List<Building>.toBuildingSections(): List<BuildingSection> {
    fun buildingsIn(section: CampusSection): List<Building> {
        return filter { building -> building.campusSection == section }
            .sortedBy { building -> building.name }
    }

    return listOf(
        BuildingSection("Upper Campus", buildingsIn(CampusSection.UPPER)),
        BuildingSection("Middle Campus", buildingsIn(CampusSection.MIDDLE)),
        BuildingSection("Lower Campus", buildingsIn(CampusSection.LOWER)),
    )
}
