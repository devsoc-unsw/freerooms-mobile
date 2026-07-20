package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.Gold
import com.devsoc.freerooms.feature.rooms.data.Room
import com.devsoc.freerooms.feature.rooms.data.statusText
import java.util.Locale

@Composable
internal fun RoomDetailsSheetHeader(
    room: Room?,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.Top,
        ) {
            Text(
                text = room?.name.orEmpty(),
                modifier = Modifier
                    .weight(1f)
                    .padding(end = 12.dp),
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = Brown,
            )

            room?.overallRating?.let { rating ->
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        text = String.format(Locale.US, "%.1f", rating),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = Brown,
                    )
                    Icon(
                        imageVector = Icons.Filled.Star,
                        contentDescription = null,
                        modifier = Modifier
                            .padding(start = 4.dp)
                            .size(18.dp),
                        tint = Gold,
                    )
                }
            }
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = room?.abbr.orEmpty(),
                modifier = Modifier.weight(1f),
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Bold,
                color = Brown,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )

            if (room != null) {
                Text(
                    text = room.statusText,
                    style = MaterialTheme.typography.bodyMedium,
                    color = roomStatusColor(room.status),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
    }
}
