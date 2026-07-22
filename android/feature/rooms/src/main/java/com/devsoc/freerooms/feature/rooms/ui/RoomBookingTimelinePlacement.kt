package com.devsoc.freerooms.feature.rooms.ui

import com.devsoc.freerooms.feature.rooms.data.RoomBooking
import java.time.LocalDate
import java.time.ZoneId

internal data class TimelinePlacement(
    val name: String,
    val timeRange: String,
    val startMinute: Int,
    val endMinute: Int,
)

internal fun RoomBooking.toTimelinePlacement(
    date: LocalDate,
    zoneId: ZoneId,
    use12HourClock: Boolean = false,
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
        timeRange = "${formatBookingTime(bookingStart.toLocalTime(), use12HourClock)}-" +
            formatBookingTime(bookingEnd.toLocalTime(), use12HourClock),
        startMinute = clippedStart,
        endMinute = clippedEnd,
    )
}
