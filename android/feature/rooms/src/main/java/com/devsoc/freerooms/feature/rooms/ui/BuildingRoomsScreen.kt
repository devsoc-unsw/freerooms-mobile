package com.devsoc.freerooms.feature.rooms.ui

import androidx.annotation.DrawableRes
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.FR_Orange
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.core.ui.Gray2
import com.devsoc.freerooms.core.ui.RoomListRowSkeleton
import com.devsoc.freerooms.core.ui.SectionCard
import com.devsoc.freerooms.core.ui.SectionCardItem
import com.devsoc.freerooms.core.ui.SectionHeader
import com.devsoc.freerooms.core.ui.SectionShape
import com.devsoc.freerooms.core.ui.SectionSkeleton
import com.devsoc.freerooms.core.ui.freeroomsClickable
import com.devsoc.freerooms.feature.rooms.data.Room

@Composable
fun BuildingRoomsScreen(
    buildingName: String,
    @DrawableRes buildingImageResId: Int?,
    rooms: List<Room>,
    roomsLoading: Boolean,
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
    onRoomClick: ((Room) -> Unit)? = null,
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
                                            onClick = onRoomClick?.let { click ->
                                                { click(room) }
                                            },
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

@Composable
private fun BuildingRoomsTopBar(
    buildingName: String,
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .background(Gray)
            .height(56.dp)
            .padding(horizontal = 4.dp),
    ) {
        Row(
            modifier = Modifier
                .align(Alignment.CenterStart)
                .freeroomsClickable(onClick = onBack)
                .padding(horizontal = 8.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = null,
                modifier = Modifier.size(20.dp),
                tint = FR_Orange,
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text(
                text = "Buildings",
                style = MaterialTheme.typography.bodyLarge,
                color = FR_Orange,
            )
        }

        Text(
            text = buildingName,
            modifier = Modifier
                .align(Alignment.Center)
                .padding(horizontal = 120.dp),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold,
            color = Brown,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

@Composable
private fun BuildingHeroImage(
    buildingName: String,
    @DrawableRes buildingImageResId: Int?,
    modifier: Modifier = Modifier,
) {
    val imageModifier = modifier
        .fillMaxWidth()
        .aspectRatio(4f / 3f)
        .clip(SectionShape)

    if (buildingImageResId != null) {
        Image(
            painter = painterResource(buildingImageResId),
            contentDescription = buildingName,
            modifier = imageModifier,
            contentScale = ContentScale.Crop,
        )
    } else {
        Box(
            modifier = imageModifier.background(Gray2),
        )
    }
}
