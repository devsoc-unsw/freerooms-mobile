package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.HorizontalDivider
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import com.devsoc.freerooms.feature.rooms.data.RoomBooking
import java.time.LocalDate
import java.time.ZoneId

@Composable
internal fun RoomBookingsDayPage(
    date: LocalDate,
    bookings: List<RoomBooking>,
    lineColor: Color,
    modifier: Modifier = Modifier,
    zoneId: ZoneId = ZoneId.systemDefault(),
) {
    val placements = remember(bookings, date, zoneId) {
        bookings
            .mapNotNull { booking -> booking.toTimelinePlacement(date, zoneId) }
            .sortedBy { placement -> placement.startMinute }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState()),
    ) {
        Box(modifier = Modifier.fillMaxWidth()) {
            HorizontalDivider(
                thickness = ThickLine,
                color = lineColor,
            )
            Box(
                modifier = Modifier
                    .align(Alignment.CenterStart)
                    .padding(start = TimeColumnWidth)
                    .width(ThinLine)
                    .height(ThickLine)
                    .background(lineColor),
            )
        }

        Box(modifier = Modifier.fillMaxWidth()) {
            RoomBookingsHourGrid(lineColor = lineColor)
            RoomBookingsTimelineOverlay(
                placements = placements,
                modifier = Modifier.matchParentSize(),
            )
        }
    }
}
