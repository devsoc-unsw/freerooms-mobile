package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.FR_Orange
import com.devsoc.freerooms.core.ui.Gray3
import com.devsoc.freerooms.feature.rooms.data.RoomBooking
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.time.ZoneId
import java.time.temporal.ChronoUnit

private const val DayPagerCenterPage = Int.MAX_VALUE / 2

@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun RoomBookingsTimeline(
    bookings: List<RoomBooking>,
    modifier: Modifier = Modifier,
    initialDate: LocalDate = LocalDate.now(),
    zoneId: ZoneId = ZoneId.systemDefault(),
) {
    val pagerState = rememberPagerState(
        initialPage = DayPagerCenterPage,
        pageCount = { Int.MAX_VALUE },
    )
    val scope = rememberCoroutineScope()
    var showDatePicker by remember { mutableStateOf(false) }
    val lineColor = Gray3
    val selectedDate = remember(pagerState.currentPage, initialDate) {
        initialDate.plusDays((pagerState.currentPage - DayPagerCenterPage).toLong())
    }

    if (showDatePicker) {
        RoomBookingsDatePickerDialog(
            selectedDate = selectedDate,
            onDateSelected = { date ->
                showDatePicker = false
                val days = ChronoUnit.DAYS.between(initialDate, date)
                scope.launch {
                    pagerState.animateScrollToPage(DayPagerCenterPage + days.toInt())
                }
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

        HorizontalPager(
            state = pagerState,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 12.dp)
                .weight(1f),
            beyondViewportPageCount = 1,
        ) { page ->
            val pageDate = initialDate.plusDays((page - DayPagerCenterPage).toLong())
            RoomBookingsDayPage(
                date = pageDate,
                bookings = bookings,
                lineColor = lineColor,
                zoneId = zoneId,
            )
        }
    }
}
