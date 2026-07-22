package com.devsoc.freerooms.core.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun BuildingListRowSkeleton(
    modifier: Modifier = Modifier,
) {
    val alpha = rememberSkeletonPulseAlpha()
    val skeletonColor = MaterialTheme.colorScheme.surfaceVariant

    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        SkeletonBlock(
            color = skeletonColor,
            alpha = alpha,
            modifier = Modifier.listThumbnail(),
        )

        Spacer(modifier = Modifier.width(ListThumbnailSpacing))

        Column(
            modifier = Modifier
                .weight(1f)
                .padding(end = 16.dp),
        ) {
            SkeletonBlock(
                color = skeletonColor,
                alpha = alpha,
                modifier = Modifier
                    .fillMaxWidth(0.72f)
                    .height(18.dp),
            )
            Spacer(modifier = Modifier.height(8.dp))
            SkeletonBlock(
                color = skeletonColor,
                alpha = alpha,
                modifier = Modifier
                    .fillMaxWidth(0.48f)
                    .height(14.dp),
            )
        }

        SkeletonBlock(
            color = skeletonColor,
            alpha = alpha,
            modifier = Modifier
                .width(28.dp)
                .height(14.dp),
        )

        SkeletonBlock(
            color = skeletonColor,
            alpha = alpha,
            modifier = Modifier
                .padding(start = 4.dp)
                .size(18.dp),
        )

        Spacer(modifier = Modifier.width(8.dp))

        SkeletonBlock(
            color = skeletonColor,
            alpha = alpha,
            modifier = Modifier.size(18.dp),
        )
    }
}
