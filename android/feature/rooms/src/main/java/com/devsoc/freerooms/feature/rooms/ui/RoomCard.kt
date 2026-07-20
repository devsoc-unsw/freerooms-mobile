package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import com.devsoc.freerooms.core.ui.FreeroomsListRow
import com.devsoc.freerooms.core.ui.Gold
import com.devsoc.freerooms.core.ui.Gray2
import com.devsoc.freerooms.core.ui.Gray3
import com.devsoc.freerooms.core.ui.Green
import com.devsoc.freerooms.core.ui.Red
import com.devsoc.freerooms.core.ui.listThumbnail
import com.devsoc.freerooms.feature.rooms.data.Room
import com.devsoc.freerooms.feature.rooms.data.RoomAvailability

@Composable
internal fun RoomCard(
    room: Room,
    modifier: Modifier = Modifier,
) {
    FreeroomsListRow(
        title = room.name,
        subtitle = room.statusText,
        subtitleColor = roomStatusColor(room.status),
        overallRating = room.overallRating,
        modifier = modifier,
    ) {
        Box(
            modifier = Modifier
                .listThumbnail()
                .background(Gray2),
        ) {
            val imageResId = roomImageResId(room.id)
            if (imageResId != null) {
                Image(
                    painter = painterResource(id = imageResId),
                    contentDescription = null,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop,
                )
            }
        }
    }
}

private fun roomStatusColor(status: RoomAvailability): Color = when (status) {
    RoomAvailability.AVAILABLE -> Green
    RoomAvailability.AVAILABLE_SOON -> Gold
    RoomAvailability.UNAVAILABLE -> Red
    RoomAvailability.UNKNOWN -> Gray3
}
