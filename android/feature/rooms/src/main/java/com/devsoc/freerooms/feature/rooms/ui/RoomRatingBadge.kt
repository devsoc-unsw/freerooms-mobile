package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.FR_Orange
import java.util.Locale

internal val RatingBadgeHeight = 36.dp
private val RatingBadgeShape = RoundedCornerShape(10.dp)

@Composable
internal fun RoomRatingBadge(
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
