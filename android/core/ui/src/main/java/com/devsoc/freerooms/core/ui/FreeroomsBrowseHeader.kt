package com.devsoc.freerooms.core.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.SwapVert
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
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
    val appUi = LocalAppUiSettings.current
    val iconTint = MaterialTheme.colorScheme.onSurfaceVariant
    val titleColor = MaterialTheme.colorScheme.onBackground

    Row(
        modifier = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = title,
            modifier = Modifier.weight(1f),
            style = MaterialTheme.typography.headlineLarge,
            fontWeight = FontWeight.Bold,
            color = titleColor,
        )

        HeaderIconButton(
            onClick = onSortClick,
            contentDescription = "Sort",
            imageVector = Icons.Filled.SwapVert,
            tint = iconTint,
        )

        HeaderIconButton(
            onClick = onViewModeClick,
            contentDescription = when (viewMode) {
                ListViewMode.LIST -> "Show grid"
                ListViewMode.GRID -> "Show list"
            },
            imageVector = when (viewMode) {
                ListViewMode.LIST -> Icons.Filled.GridView
                ListViewMode.GRID -> Icons.AutoMirrored.Filled.List
            },
            tint = iconTint,
        )

        HeaderIconButton(
            onClick = { appUi.setUse12HourClock(!appUi.use12HourClock) },
            contentDescription = if (appUi.use12HourClock) {
                "Use 24-hour time"
            } else {
                "Use 12-hour time"
            },
            imageVector = Icons.Filled.Schedule,
            tint = if (appUi.use12HourClock) MaterialTheme.colorScheme.primary else iconTint,
        )

        HeaderIconButton(
            onClick = { appUi.setDarkMode(!appUi.darkMode) },
            contentDescription = if (appUi.darkMode) {
                "Use light mode"
            } else {
                "Use dark mode"
            },
            imageVector = if (appUi.darkMode) {
                Icons.Filled.LightMode
            } else {
                Icons.Filled.DarkMode
            },
            tint = if (appUi.darkMode) MaterialTheme.colorScheme.primary else iconTint,
        )
    }
}

@Composable
private fun HeaderIconButton(
    onClick: () -> Unit,
    contentDescription: String,
    imageVector: ImageVector,
    tint: Color,
) {
    Box(
        modifier = Modifier
            .freeroomsClickable(onClick = onClick)
            .padding(8.dp),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            imageVector = imageVector,
            contentDescription = contentDescription,
            modifier = Modifier.size(22.dp),
            tint = tint,
        )
    }
}
