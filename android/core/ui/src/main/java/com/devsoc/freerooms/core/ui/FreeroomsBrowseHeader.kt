package com.devsoc.freerooms.core.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.SwapVert
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

@Composable
fun FreeroomsBrowseHeader(
    title: String,
    viewMode: ListViewMode,
    onSortClick: () -> Unit,
    onViewModeClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = title,
            modifier = Modifier.weight(1f),
            style = MaterialTheme.typography.headlineLarge,
            fontWeight = FontWeight.Bold,
            color = Brown,
        )

        Box(
            modifier = Modifier
                .freeroomsClickable(onClick = onSortClick)
                .padding(8.dp),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = Icons.Filled.SwapVert,
                contentDescription = "Sort",
                modifier = Modifier.size(22.dp),
                tint = Gray3,
            )
        }

        Box(
            modifier = Modifier
                .freeroomsClickable(onClick = onViewModeClick)
                .padding(8.dp),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = when (viewMode) {
                    ListViewMode.LIST -> Icons.Filled.GridView
                    ListViewMode.GRID -> Icons.AutoMirrored.Filled.List
                },
                contentDescription = when (viewMode) {
                    ListViewMode.LIST -> "Show grid"
                    ListViewMode.GRID -> "Show list"
                },
                modifier = Modifier.size(22.dp),
                tint = Gray3,
            )
        }
    }
}
