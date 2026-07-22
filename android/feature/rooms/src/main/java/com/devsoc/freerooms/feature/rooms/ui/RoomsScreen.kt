package com.devsoc.freerooms.feature.rooms.ui

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
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.FreeroomsSearchBox
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.core.ui.RoomListRowSkeleton
import com.devsoc.freerooms.core.ui.SectionCard
import com.devsoc.freerooms.core.ui.SectionCardItem
import com.devsoc.freerooms.core.ui.SectionHeader
import com.devsoc.freerooms.core.ui.SectionSkeleton
import com.devsoc.freerooms.feature.rooms.BuildConfig
import com.devsoc.freerooms.feature.rooms.data.Room
import com.devsoc.freerooms.feature.rooms.data.RoomViewModel
import com.devsoc.freerooms.feature.rooms.data.filterBySearchQuery

@Composable
fun RoomsScreen(
    viewModel: RoomViewModel,
    modifier: Modifier = Modifier,
    onRoomClick: (Room) -> Unit = {},
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    var searchQuery by rememberSaveable { mutableStateOf("") }

    if (BuildConfig.DEBUG) {
        LaunchedEffect(uiState) { Log.d("RoomScreen", "UI State: $uiState") }
    }

    when (val state = uiState) {
        is ResponseState.Loading -> {
            RoomsListScaffold(
                searchQuery = searchQuery,
                onSearchQueryChange = { searchQuery = it },
                modifier = modifier,
            ) {
                item(
                    key = "placeholder-all-rooms",
                    contentType = "section-skeleton",
                ) {
                    SectionSkeleton(
                        title = "All Rooms",
                        rowCount = 8,
                    ) {
                        RoomListRowSkeleton()
                    }
                }
            }
        }
        is ResponseState.Error -> {
            if (BuildConfig.DEBUG) {
                Log.e("RoomScreen", "Displaying Error: ${state.exception.message}", state.exception)
            }
            Text("Error: ${state.exception.message}", modifier = modifier)
        }
        is ResponseState.Success -> {
            val filteredRooms = remember(state.data, searchQuery) {
                state.data.filterBySearchQuery(searchQuery)
            }

            RoomsListScaffold(
                searchQuery = searchQuery,
                onSearchQueryChange = { searchQuery = it },
                modifier = modifier,
            ) {
                item(
                    key = "all-rooms",
                    contentType = "section",
                ) {
                    SectionHeader(
                        title = "All Rooms",
                        modifier = Modifier.padding(bottom = 8.dp),
                    )

                    SectionCard {
                        filteredRooms.forEachIndexed { index, room ->
                            SectionCardItem(
                                showDivider = index != filteredRooms.lastIndex,
                                isFirst = index == 0,
                                isLast = index == filteredRooms.lastIndex,
                            ) {
                                RoomCard(
                                    room = room,
                                    onClick = { onRoomClick(room) },
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun RoomsListScaffold(
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
                text = "Rooms",
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
