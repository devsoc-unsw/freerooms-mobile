package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.FR_Orange
import com.devsoc.freerooms.core.ui.Gray3
import com.devsoc.freerooms.feature.rooms.data.RoomBooking
import java.time.LocalDate
import java.time.ZoneId

@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun RoomBookingsTimeline(
    bookings: List<RoomBooking>,
    modifier: Modifier = Modifier,
    initialDate: LocalDate = LocalDate.now(),
    zoneId: ZoneId = ZoneId.systemDefault(),
) {
    var selectedDate by remember { mutableStateOf(initialDate) }
    var showDatePicker by remember { mutableStateOf(false) }
    val lineColor = Gray3
    val visibleBookings = remember(bookings, selectedDate, zoneId) {
        bookings
            .mapNotNull { booking -> booking.toTimelinePlacement(selectedDate, zoneId) }
            .sortedBy { placement -> placement.startMinute }
    }

    if (showDatePicker) {
        RoomBookingsDatePickerDialog(
            selectedDate = selectedDate,
            onDateSelected = { date ->
                selectedDate = date
                showDatePicker = false
            },
            onDismiss = { showDatePicker = false },
        )
    }

    Column(
        modifier = modifier
            .border(1.dp, FR_Orange, BookingsBoxShape)
            .padding(12.dp),
    ) {
        RoomBookingsTimelineHeader(
            selectedDate = selectedDate,
            onDateClick = { showDatePicker = true },
        )

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 12.dp)
                .weight(1f)
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
                    placements = visibleBookings,
                    modifier = Modifier.matchParentSize(),
                )
            }
        }
    }
}
