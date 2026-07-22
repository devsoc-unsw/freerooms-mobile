package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.FR_Orange
import com.devsoc.freerooms.core.ui.Gray2
import com.devsoc.freerooms.core.ui.freeroomsClickable
import com.devsoc.freerooms.feature.rooms.data.Room
import com.devsoc.freerooms.feature.rooms.data.statusText
import java.util.Locale

private val RatingBadgeHeight = 36.dp
private val RatingBadgeShape = RoundedCornerShape(10.dp)

@Composable
internal fun RoomDetailsSheetHeader(
    room: Room?,
    overallRating: Double?,
    isFavorite: Boolean,
    onToggleFavorite: () -> Unit,
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

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                RoomRatingBadge(overallRating = overallRating ?: 0.0)
                RoomFavoriteButton(
                    isFavorite = isFavorite,
                    onToggleFavorite = onToggleFavorite,
                )
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

@Composable
private fun RoomRatingBadge(
    overallRating: Double,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .height(RatingBadgeHeight)
            .clip(RatingBadgeShape)
            .background(FR_Orange)
            .padding(start = 10.dp, end = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(2.dp),
    ) {
        Text(
            text = String.format(Locale.US, "%.1f", overallRating),
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.Bold,
            color = Color.White,
        )
        Icon(
            imageVector = Icons.Filled.Star,
            contentDescription = null,
            modifier = Modifier.size(16.dp),
            tint = Color.White,
        )
    }
}

@Composable
private fun RoomFavoriteButton(
    isFavorite: Boolean,
    onToggleFavorite: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier
            .size(RatingBadgeHeight)
            .clip(CircleShape)
            .background(Gray2)
            .freeroomsClickable(onClick = onToggleFavorite),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            imageVector = if (isFavorite) {
                Icons.Filled.Favorite
            } else {
                Icons.Outlined.FavoriteBorder
            },
            contentDescription = if (isFavorite) {
                "Remove as favourite"
            } else {
                "Add as favourite"
            },
            modifier = Modifier.size(18.dp),
            tint = FR_Orange,
        )
    }
}
