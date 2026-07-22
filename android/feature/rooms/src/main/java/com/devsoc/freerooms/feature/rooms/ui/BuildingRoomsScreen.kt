package com.devsoc.freerooms.feature.rooms.ui

import androidx.annotation.DrawableRes
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.RoomListRowSkeleton
import com.devsoc.freerooms.core.ui.SectionHeader
import com.devsoc.freerooms.core.ui.SectionSkeleton
import com.devsoc.freerooms.core.ui.sectionCardItems
import com.devsoc.freerooms.feature.rooms.data.Room

@Composable
fun BuildingRoomsScreen(
    buildingName: String,
    @DrawableRes buildingImageResId: Int?,
    rooms: List<Room>,
    roomsLoading: Boolean,
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
    onRoomClick: (Room) -> Unit = {},
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
    ) {
        BuildingRoomsTopBar(
            buildingName = buildingName,
            onBack = onBack,
        )

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 16.dp),
        ) {
            item(key = "building-image") {
                BuildingHeroImage(
                    buildingName = buildingName,
                    buildingImageResId = buildingImageResId,
                )
            }

            if (roomsLoading && rooms.isEmpty()) {
                item(key = "rooms-skeleton") {
                    SectionSkeleton(
                        title = "Rooms",
                        rowCount = 6,
                        topPadding = 16.dp,
                    ) {
                        RoomListRowSkeleton()
                    }
                }
            } else {
                item(key = "rooms-header") {
                    SectionHeader(
                        title = "Rooms",
                        modifier = Modifier.padding(top = 16.dp, bottom = 10.dp),
                    )
                }

                if (rooms.isEmpty()) {
                    item(key = "rooms-empty") {
                        Text(
                            text = "No rooms found",
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(20.dp),
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onBackground,
                        )
                    }
                } else {
                    sectionCardItems(
                        items = rooms,
                        key = Room::id,
                    ) { room ->
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
