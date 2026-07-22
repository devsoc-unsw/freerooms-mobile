package com.devsoc.freerooms.core.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Apartment
import androidx.compose.material.icons.outlined.DoorFront
import androidx.compose.material.icons.outlined.Map
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp

@Composable
fun FreeroomsBottomNavBar(
    selectedPage: FreeroomsPage,
    onPageSelected: (FreeroomsPage) -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .height(96.dp)
            .background(MaterialTheme.colorScheme.surface),
    ) {
        HorizontalDivider(
            thickness = 1.dp,
            color = MaterialTheme.colorScheme.surfaceVariant,
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            FreeroomsPage.entries.forEach { page ->
                val itemColor = if (page == selectedPage) {
                    MaterialTheme.colorScheme.primary
                } else {
                    MaterialTheme.colorScheme.onSurfaceVariant
                }

                Column(
                    modifier = Modifier
                        .weight(1f)
                        .freeroomsClickable(enabled = page != selectedPage) {
                            onPageSelected(page)
                        },
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    Icon(
                        imageVector = page.icon,
                        contentDescription = page.label,
                        modifier = Modifier.size(36.dp),
                        tint = itemColor,
                    )

                    Text(
                        text = page.label,
                        style = MaterialTheme.typography.labelMedium,
                        color = itemColor,
                    )
                }
            }
        }
    }
}

private val FreeroomsPage.icon: ImageVector
    get() = when (this) {
        FreeroomsPage.Building -> Icons.Outlined.Apartment
        FreeroomsPage.Map -> Icons.Outlined.Map
        FreeroomsPage.Rooms -> Icons.Outlined.DoorFront
    }
