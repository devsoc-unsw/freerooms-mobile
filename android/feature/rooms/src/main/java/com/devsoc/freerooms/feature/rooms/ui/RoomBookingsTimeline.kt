package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.FR_Orange
import com.devsoc.freerooms.core.ui.Gray3
import com.devsoc.freerooms.feature.rooms.data.RoomBooking
import java.time.LocalDate
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale
import kotlin.math.roundToInt

private val BookingsBoxShape = RoundedCornerShape(12.dp)
private val DateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.US)
private val TimeFormatter = DateTimeFormatter.ofPattern("HH:mm", Locale.US)
private val TimelineHours = 9..23
private val SlotHeight = 60.dp
private val TimeColumnWidth = 52.dp
private val ThickLine = 2.dp
private val ThinLine = 1.dp
private val TimelineStartHour = 9
private val TimelineEndHour = 24

@Composable
internal fun RoomBookingsTimeline(
    bookings: List<RoomBooking>,
    modifier: Modifier = Modifier,
    date: LocalDate = LocalDate.now(),
    zoneId: ZoneId = ZoneId.systemDefault(),
) {
    val lineColor = Gray3
    val density = LocalDensity.current
    val slotHeightPx = with(density) { SlotHeight.toPx() }
    val visibleBookings = remember(bookings, date, zoneId) {
        bookings
            .mapNotNull { booking -> booking.toTimelinePlacement(date, zoneId) }
            .sortedBy { placement -> placement.startMinute }
    }

    Column(
        modifier = modifier
            .border(1.dp, FR_Orange, BookingsBoxShape)
            .padding(12.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "Room Bookings",
                modifier = Modifier.weight(1f),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
                color = Brown,
            )
            Text(
                text = date.format(DateFormatter),
                style = MaterialTheme.typography.bodyMedium,
                color = Brown,
            )
        }

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
                Column(modifier = Modifier.fillMaxWidth()) {
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
                                text = String.format(Locale.US, "%02d:00", hour),
                                modifier = Modifier
                                    .align(Alignment.TopStart)
                                    .width(TimeColumnWidth)
                                    .padding(end = 8.dp),
                                style = MaterialTheme.typography.bodyMedium,
                                color = Brown,
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

                Box(
                    modifier = Modifier
                        .matchParentSize()
                        .padding(start = TimeColumnWidth + ThinLine + 4.dp, end = 4.dp),
                ) {
                    val endLineGapPx = with(density) { ThickLine.toPx() }
                    visibleBookings.forEach { placement ->
                        val topPx = ((placement.startMinute - TimelineStartHour * 60) / 60f) *
                            slotHeightPx
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
        }
    }
}

private data class TimelinePlacement(
    val name: String,
    val timeRange: String,
    val startMinute: Int,
    val endMinute: Int,
)

private fun RoomBooking.toTimelinePlacement(
    date: LocalDate,
    zoneId: ZoneId,
): TimelinePlacement? {
    val dayStart = date.atStartOfDay(zoneId)
    val dayEnd = date.plusDays(1).atStartOfDay(zoneId)
    val bookingStart = start.atZone(zoneId)
    val bookingEnd = end.atZone(zoneId)

    val visibleStart = maxOf(bookingStart, dayStart)
    val visibleEnd = minOf(bookingEnd, dayEnd)
    if (!visibleEnd.isAfter(visibleStart)) return null

    val startMinute = visibleStart.hour * 60 + visibleStart.minute
    val endMinute = if (visibleEnd == dayEnd) {
        TimelineEndHour * 60
    } else {
        visibleEnd.hour * 60 + visibleEnd.minute
    }

    val clippedStart = startMinute.coerceIn(TimelineStartHour * 60, TimelineEndHour * 60)
    val clippedEnd = endMinute.coerceIn(TimelineStartHour * 60, TimelineEndHour * 60)
    if (clippedEnd <= clippedStart) return null

    return TimelinePlacement(
        name = name,
        timeRange = "${bookingStart.toLocalTime().format(TimeFormatter)}-" +
            bookingEnd.toLocalTime().format(TimeFormatter),
        startMinute = clippedStart,
        endMinute = clippedEnd,
    )
}
