package com.devsoc.freerooms.core.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import java.util.Locale

private val GridCardShape = RoundedCornerShape(22.dp)
private val GridImageShape = RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp)
private val RatingBadgeShape = RoundedCornerShape(8.dp)

@Composable
fun FreeroomsGridCard(
    title: String,
    subtitle: String?,
    overallRating: Double?,
    modifier: Modifier = Modifier,
    subtitleColor: Color = Color.Unspecified,
    onClick: (() -> Unit)? = null,
    image: @Composable () -> Unit,
) {
    val colors = MaterialTheme.colorScheme
    val resolvedSubtitleColor = if (subtitleColor == Color.Unspecified) {
        colors.onSurfaceVariant
    } else {
        subtitleColor
    }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(GridCardShape)
            .background(colors.surface)
            .then(
                if (onClick != null) {
                    Modifier.freeroomsClickable(onClick = onClick)
                } else {
                    Modifier
                },
            ),
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(16f / 11f)
                .clip(GridImageShape)
                .background(colors.surfaceVariant),
        ) {
            image()
        }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 10.dp, vertical = 10.dp),
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = title,
                    modifier = Modifier.weight(1f),
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Bold,
                    color = colors.onSurface,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )

                Row(
                    modifier = Modifier
                        .padding(start = 6.dp)
                        .clip(RatingBadgeShape)
                        .background(colors.primary)
                        .padding(horizontal = 6.dp, vertical = 3.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        text = String.format(Locale.US, "%.1f", overallRating ?: 0.0),
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = FontWeight.SemiBold,
                        color = colors.onPrimary,
                    )
                    Icon(
                        imageVector = Icons.Filled.Star,
                        contentDescription = null,
                        modifier = Modifier
                            .padding(start = 2.dp)
                            .size(12.dp),
                        tint = colors.onPrimary,
                    )
                }
            }

            if (subtitle != null) {
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = resolvedSubtitleColor,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
    }
}
