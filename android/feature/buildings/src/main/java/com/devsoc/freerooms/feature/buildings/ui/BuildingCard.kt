package com.devsoc.freerooms.feature.buildings.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.Gold
import com.devsoc.freerooms.core.ui.Gray2
import com.devsoc.freerooms.core.ui.Gray3
import com.devsoc.freerooms.core.ui.ListThumbnailSpacing
import com.devsoc.freerooms.core.ui.listThumbnail
import com.devsoc.freerooms.feature.buildings.R
import com.devsoc.freerooms.feature.buildings.data.Building
import java.util.Locale

@Composable
internal fun BuildingCard(
    building: Building,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
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
                modifier = imageModifier.background(Gray2),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    painter = painterResource(R.drawable.ic_building),
                    contentDescription = null,
                    modifier = Modifier.size(24.dp),
                    tint = Brown,
                )
            }
        }

        Spacer(modifier = Modifier.width(ListThumbnailSpacing))

        Column(
            modifier = Modifier
                .weight(1f)
                .padding(end = 16.dp),
        ) {
            Text(
                text = building.name,
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Bold,
                color = Brown,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Text(
                text = availableRoomsLabel(building.numberOfAvailableRooms),
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Normal,
                color = Brown,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }

        building.overallRating?.let { rating ->
            Text(
                text = String.format(Locale.US, "%.1f", rating),
                style = MaterialTheme.typography.bodyMedium,
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

        Spacer(modifier = Modifier.width(8.dp))

        Icon(
            imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
            contentDescription = null,
            modifier = Modifier.size(24.dp),
            tint = Gray3,
        )
    }
}

private fun availableRoomsLabel(count: Int?): String {
    val available = count ?: 0
    return if (available == 1) {
        "1 room available"
    } else {
        "$available rooms available"
    }
}
