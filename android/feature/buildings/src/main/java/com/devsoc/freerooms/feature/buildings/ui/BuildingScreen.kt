package com.devsoc.freerooms.feature.buildings.ui

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.devsoc.freerooms.core.ui.BuildingListRowSkeleton
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.FreeroomsSearchBox
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.core.ui.SectionCard
import com.devsoc.freerooms.core.ui.SectionCardItem
import com.devsoc.freerooms.core.ui.SectionHeader
import com.devsoc.freerooms.core.ui.SectionSkeleton
import com.devsoc.freerooms.feature.buildings.BuildConfig
import com.devsoc.freerooms.feature.buildings.data.Building
import com.devsoc.freerooms.feature.buildings.data.BuildingViewModel
import com.devsoc.freerooms.feature.buildings.data.CampusSection
import com.devsoc.freerooms.feature.buildings.data.filterBySearchQuery

private val PlaceholderCampusSections = listOf(
    "Upper Campus",
    "Middle Campus",
    "Lower Campus",
)

@Composable
fun BuildingScreen(
    viewModel: BuildingViewModel,
    modifier: Modifier = Modifier,
    onBuildingClick: (Building) -> Unit = {},
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    var searchQuery by rememberSaveable { mutableStateOf("") }

    if (BuildConfig.DEBUG) {
        LaunchedEffect(uiState) { Log.d("BuildingScreen", "UI State: $uiState") }
    }

    when (val state = uiState) {
        is ResponseState.Loading -> {
            BuildingListScaffold(
                searchQuery = searchQuery,
                onSearchQueryChange = { searchQuery = it },
                modifier = modifier,
            ) {
                PlaceholderCampusSections.forEachIndexed { sectionIndex, title ->
                    item(
                        key = "placeholder-$title",
                        contentType = "section-skeleton",
                    ) {
                        SectionSkeleton(
                            title = title,
                            rowCount = 5,
                            topPadding = if (sectionIndex == 0) 0.dp else 20.dp,
                        ) {
                            BuildingListRowSkeleton()
                        }
                    }
                }
            }
        }
        is ResponseState.Error -> {
            if (BuildConfig.DEBUG) {
                Log.e("BuildingScreen", "Displaying Error: ${state.exception.message}", state.exception)
            }
            Text("Error: ${state.exception.message}", modifier = modifier)
        }
        is ResponseState.Success -> {
            val buildingSections = remember(state.data, searchQuery) {
                state.data.filterBySearchQuery(searchQuery).toBuildingSections()
            }

            BuildingListScaffold(
                searchQuery = searchQuery,
                onSearchQueryChange = { searchQuery = it },
                modifier = modifier,
            ) {
                buildingSections.forEachIndexed { sectionIndex, section ->
                    if (section.buildings.isEmpty()) return@forEachIndexed

                    item(
                        key = "section-${section.title}",
                        contentType = "section",
                    ) {
                        SectionHeader(
                            title = section.title,
                            modifier = Modifier.padding(
                                top = if (sectionIndex == 0) 0.dp else 20.dp,
                                bottom = 10.dp,
                            ),
                        )

                        SectionCard {
                            section.buildings.forEachIndexed { index, building ->
                                SectionCardItem(
                                    showDivider = index != section.buildings.lastIndex,
                                    isFirst = index == 0,
                                    isLast = index == section.buildings.lastIndex,
                                ) {
                                    BuildingCard(
                                        building = building,
                                        onClick = { onBuildingClick(building) },
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun BuildingListScaffold(
    searchQuery: String,
    onSearchQueryChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    sections: LazyListScope.() -> Unit,
) {
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
            FreeroomsSearchBox(
                query = searchQuery,
                onQueryChange = onSearchQueryChange,
                modifier = Modifier.padding(bottom = 12.dp),
            )
        }

        sections()
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
