package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
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
import com.devsoc.freerooms.core.ui.FR_Orange
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.core.ui.freeroomsClickable

@Composable
internal fun BuildingRoomsTopBar(
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
                contentDescription = "Back",
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
