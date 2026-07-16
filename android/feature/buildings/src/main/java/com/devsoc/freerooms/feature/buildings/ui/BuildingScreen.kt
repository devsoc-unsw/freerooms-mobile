package com.devsoc.freerooms.feature.buildings.ui

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.core.ui.SectionCardItem
import com.devsoc.freerooms.core.ui.SectionHeader
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
                contentPadding = PaddingValues(
                    start = 16.dp,
                    top = 16.dp,
                    end = 16.dp,
                    bottom = 16.dp,
                ),
            ) {
                item {
                    Text(
                        text = "Buildings",
                        modifier = Modifier.padding(bottom = 12.dp),
                        style = MaterialTheme.typography.headlineLarge,
                        fontWeight = FontWeight.Bold,
                        color = Brown,
                    )
                }

                item {
                    BuildingSearchBox(modifier = Modifier.padding(bottom = 12.dp))
                }

                buildingSections.forEachIndexed { sectionIndex, section ->
                    item(
                        key = "section-${section.title}",
                        contentType = "section-header",
                    ) {
                        SectionHeader(
                            title = section.title,
                            modifier = Modifier.padding(
                                top = if (sectionIndex == 0) 0.dp else 12.dp,
                                bottom = 8.dp,
                            ),
                        )
                    }

                    itemsIndexed(
                        items = section.buildings,
                        key = { _, building -> building.id },
                        contentType = { _, _ -> "building" },
                    ) { index, building ->
                        SectionCardItem(
                            isFirst = index == 0,
                            isLast = index == section.buildings.lastIndex,
                        ) {
                            BuildingCard(building = building)
                        }
                    }
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
