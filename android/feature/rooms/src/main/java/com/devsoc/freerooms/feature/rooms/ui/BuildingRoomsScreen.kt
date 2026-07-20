package com.devsoc.freerooms.feature.rooms.ui

import androidx.annotation.DrawableRes
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.core.ui.RoomListRowSkeleton
import com.devsoc.freerooms.core.ui.SectionCard
import com.devsoc.freerooms.core.ui.SectionCardItem
import com.devsoc.freerooms.core.ui.SectionHeader
import com.devsoc.freerooms.core.ui.SectionSkeleton
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
            .background(Gray),
    ) {
        BuildingRoomsTopBar(
            buildingName = buildingName,
            onBack = onBack,
        )

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(bottom = 16.dp),
        ) {
            item(key = "building-image") {
                BuildingHeroImage(
                    buildingName = buildingName,
                    buildingImageResId = buildingImageResId,
                    modifier = Modifier.padding(horizontal = 16.dp),
                )
            }

            item(key = "rooms-section") {
                Column(
                    modifier = Modifier.padding(
                        start = 16.dp,
                        top = 16.dp,
                        end = 16.dp,
                    ),
                ) {
                    if (roomsLoading && rooms.isEmpty()) {
                        SectionSkeleton(
                            title = "Rooms",
                            rowCount = 6,
                        ) {
                            RoomListRowSkeleton()
                        }
                    } else {
                        SectionHeader(
                            title = "Rooms",
                            modifier = Modifier.padding(bottom = 10.dp),
                        )

                        SectionCard {
                            if (rooms.isEmpty()) {
                                Text(
                                    text = "No rooms found",
                                    modifier = Modifier.padding(20.dp),
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = Brown,
                                )
                            } else {
                                rooms.forEachIndexed { index, room ->
                                    SectionCardItem(
                                        showDivider = index != rooms.lastIndex,
                                        isFirst = index == 0,
                                        isLast = index == rooms.lastIndex,
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
    }
}
