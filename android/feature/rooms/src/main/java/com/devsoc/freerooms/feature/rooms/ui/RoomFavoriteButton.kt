package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.FR_Orange
import com.devsoc.freerooms.core.ui.Gray2
import com.devsoc.freerooms.core.ui.freeroomsClickable

@Composable
internal fun RoomFavoriteButton(
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
