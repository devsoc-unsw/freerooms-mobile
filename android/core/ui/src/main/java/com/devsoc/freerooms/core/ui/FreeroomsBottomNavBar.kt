package com.devsoc.freerooms.core.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
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
            .background(Color.White),
    ) {
        HorizontalDivider(
            thickness = 1.dp,
            color = Gray,
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            FreeroomsPage.entries.forEach { page ->
                Column(
                    modifier = Modifier
                        .weight(1f)
                        .clickable(enabled = page != selectedPage) {
                            onPageSelected(page)
                        },
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .background(Gray2, RoundedCornerShape(10.dp)),
                    )

                    Text(
                        text = page.label,
                        style = MaterialTheme.typography.labelMedium,
                        color = Brown,
                    )
                }
            }
        }
    }
}
