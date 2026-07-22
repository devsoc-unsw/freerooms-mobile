package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import com.devsoc.freerooms.core.ui.FreeroomsGridCard
import com.devsoc.freerooms.core.ui.LocalAppUiSettings
import com.devsoc.freerooms.feature.rooms.data.Room
import com.devsoc.freerooms.feature.rooms.data.statusText

@Composable
internal fun RoomGridCard(
    room: Room,
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null,
) {
    FreeroomsGridCard(
        title = room.abbr.ifBlank { room.name },
        subtitle = room.statusText(LocalAppUiSettings.current.use12HourClock),
        overallRating = room.overallRating,
        subtitleColor = roomStatusColor(room.status),
        modifier = modifier,
        onClick = onClick,
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.surfaceVariant),
        ) {
            val imageResId = roomImageResId(room.id)
            if (imageResId != null) {
                Image(
                    painter = painterResource(id = imageResId),
                    contentDescription = room.name,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop,
                )
            }
        }
    }
}
