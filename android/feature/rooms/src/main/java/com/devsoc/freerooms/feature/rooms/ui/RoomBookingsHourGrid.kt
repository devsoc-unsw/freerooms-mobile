package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.LocalAppUiSettings

@Composable
internal fun RoomBookingsHourGrid(
    lineColor: Color,
    modifier: Modifier = Modifier,
) {
    val use12HourClock = LocalAppUiSettings.current.use12HourClock
    val labelColor = MaterialTheme.colorScheme.onBackground

    Column(modifier = modifier.fillMaxWidth()) {
        TimelineHours.forEach { hour ->
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(SlotHeight),
            ) {
                HorizontalDivider(
                    modifier = Modifier.align(Alignment.Center),
                    thickness = ThinLine,
                    color = lineColor,
                )
                HorizontalDivider(
                    modifier = Modifier.align(Alignment.BottomCenter),
                    thickness = ThickLine,
                    color = lineColor,
                )

                Text(
                    text = formatHourLabel(hour, use12HourClock),
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .width(TimeColumnWidth)
                        .padding(end = 8.dp),
                    style = MaterialTheme.typography.bodyMedium,
                    color = labelColor,
                )

                Box(
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .padding(start = TimeColumnWidth)
                        .width(ThinLine)
                        .fillMaxHeight()
                        .background(lineColor),
                )
            }
        }
    }
}
