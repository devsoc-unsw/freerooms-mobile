package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.Light_Orange
import com.devsoc.freerooms.feature.rooms.data.Room

@Composable
internal fun RoomCard(
    room: Room,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(Light_Orange),
        )

        Spacer(modifier = Modifier.width(12.dp))

        Text(
            text = room.name,
            style = MaterialTheme.typography.bodyLarge,
            color = Brown,
        )
    }
}
