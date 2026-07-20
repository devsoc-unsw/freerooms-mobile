package com.devsoc.freerooms.feature.buildings.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.Light_Orange
import com.devsoc.freerooms.core.ui.ListThumbnailSpacing
import com.devsoc.freerooms.core.ui.listThumbnail
import com.devsoc.freerooms.feature.buildings.R
import com.devsoc.freerooms.feature.buildings.data.Building

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
                modifier = imageModifier.background(Light_Orange),
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

        Text(
            text = building.name,
            style = MaterialTheme.typography.bodyLarge,
            color = Brown,
        )
    }
}
