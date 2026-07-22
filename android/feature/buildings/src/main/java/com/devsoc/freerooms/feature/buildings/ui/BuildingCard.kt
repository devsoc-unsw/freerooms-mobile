package com.devsoc.freerooms.feature.buildings.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.FreeroomsListRow
import com.devsoc.freerooms.core.ui.listThumbnail
import com.devsoc.freerooms.feature.buildings.R
import com.devsoc.freerooms.feature.buildings.data.Building

@Composable
internal fun BuildingCard(
    building: Building,
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null,
) {
    val colors = MaterialTheme.colorScheme
    FreeroomsListRow(
        title = building.name,
        subtitle = availableRoomsLabel(building.numberOfAvailableRooms),
        overallRating = building.overallRating,
        modifier = modifier,
        onClick = onClick,
    ) {
        val imageModifier = Modifier.listThumbnail()
        val imageResId = buildingImageResId(building.id)
        if (imageResId != null) {
            Image(
                painter = painterResource(imageResId),
                contentDescription = building.name,
                modifier = imageModifier,
                contentScale = ContentScale.Crop,
            )
        } else {
            Box(
                modifier = imageModifier.background(colors.surfaceVariant),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    painter = painterResource(R.drawable.ic_building),
                    contentDescription = null,
                    modifier = Modifier.size(24.dp),
                    tint = colors.onBackground,
                )
            }
        }
    }
}
