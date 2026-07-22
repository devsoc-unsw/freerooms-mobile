package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import kotlin.math.roundToInt

@Composable
internal fun RoomBookingsTimelineOverlay(
    placements: List<TimelinePlacement>,
    modifier: Modifier = Modifier,
) {
    val density = LocalDensity.current
    val slotHeightPx = with(density) { SlotHeight.toPx() }
    val endLineGapPx = with(density) { ThickLine.toPx() }

    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(start = TimeColumnWidth + ThinLine + 4.dp, end = 4.dp),
    ) {
        placements.forEach { placement ->
            val topPx = ((placement.startMinute - TimelineStartHour * 60) / 60f) * slotHeightPx
            val heightPx = (
                ((placement.endMinute - placement.startMinute) / 60f) * slotHeightPx -
                    endLineGapPx
                ).coerceAtLeast(0f)

            RoomBookingCard(
                timeRange = placement.timeRange,
                who = placement.name,
                modifier = Modifier
                    .offset { IntOffset(0, topPx.roundToInt()) }
                    .height(with(density) { heightPx.toDp() })
                    .fillMaxWidth(),
            )
        }
    }
}
