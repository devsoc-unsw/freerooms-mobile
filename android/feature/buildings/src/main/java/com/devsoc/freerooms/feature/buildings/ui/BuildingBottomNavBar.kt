package com.devsoc.freerooms.feature.buildings.ui

import androidx.compose.foundation.background
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
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.core.ui.Gray2

private val BottomNavLabels = listOf("buildings", "map", "rooms") // move somewhere else later?

@Composable
internal fun BuildingBottomNavBar(
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
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            BottomNavLabels.forEach { label ->
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .background(Gray2, RoundedCornerShape(10.dp)),
                    )

                    Text(
                        text = label,
                        style = MaterialTheme.typography.labelMedium,
                        color = Brown,
                    )
                }
            }
        }
    }
}
